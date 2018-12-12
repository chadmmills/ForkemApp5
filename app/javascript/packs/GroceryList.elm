module GroceryList exposing (CurrentGroceryList(..), Flags, GeneralItem, GeneralItemForm(..), GroceryList, GroceryListResponse, GroceryListsResponse, Ingredient, IngredientListItem, IngredientListResponse, Mealbook, Message(..), Model, dateInputSettings, destroyGroceryListItem, fetchGroceryList, fetchGroceryLists, fetchIngredientsForTimeFrame, groceryListDecoder, groceryListForm, groceryListIngredientItem, groceryListItem, groceryListItemDecoder, groceryListsDecoder, ingredientItem, ingredientsListDecoder, init, main, newGroceryListForm, onCheckBoxClick, onClickPreventDefault, subscriptions, update, updateListIngredient, view)

-- import Html.Attributes exposing (..)
-- import Html.Events exposing (..)

import Date exposing (Date)
import Date.Extra as DateFormat
import DatePicker exposing (DateEvent(..), defaultSettings)
import Html exposing (..)
import Html.Attributes exposing (action, class, classList, href, method, name, placeholder, value)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Http exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode


type alias Flags =
    { csrfToken : String
    , initEndDate : String
    , initStartDate : String
    , listId : Maybe String
    , plannerId : String
    }


type alias Ingredient =
    { isCompleted : Bool
    , id : String
    , name : String
    }


type alias IngredientListItem =
    { name : String
    }


type alias Mealbook =
    { id : String }


type CurrentGroceryList
    = NewGroceryList
    | LoadingGroceryList GroceryList
    | LoadedGroceryList GroceryListResponse


type alias GroceryList =
    { id : String
    , name : String
    }


type alias IngredientListResponse =
    { groceryList : List IngredientListItem
    , mealbook : Mealbook
    }


type alias GroceryListResponse =
    { id : String
    , name : String
    , mealIngredients : List Ingredient
    }


type alias GroceryListsResponse =
    { lists : List GroceryList }


type alias GeneralItem =
    { name : String }


type GeneralItemForm
    = NoNewItem
    | NewGeneralItem GeneralItem


type alias Model =
    { csrfToken : String
    , currentGroceryList : CurrentGroceryList
    , ingredients : List IngredientListItem
    , inputStartDate : Maybe Date
    , inputEndDate : Maybe Date
    , lists : List GroceryList
    , newGeneralItemForm : GeneralItemForm
    , plannerId : String
    , queryStartDate : Date
    , queryEndDate : Date
    , startDatePicker : DatePicker.DatePicker
    , endDatePicker : DatePicker.DatePicker
    }


dateInputSettings : DatePicker.Settings
dateInputSettings =
    { defaultSettings
        | inputClassList = [ ( "input inline", True ) ]
    }


type Message
    = None
    | AddNewGeneralIngredient
    | LoadedIngredientsForNewList (Result Http.Error IngredientListResponse)
    | GroceryListLoaded (Result Http.Error GroceryListResponse)
    | GroceryListsLoaded (Result Http.Error GroceryListsResponse)
    | GroceryListItemCreated (Result Http.Error GroceryListResponse)
    | RemoveGroceryListItem String
    | SetStartDate DatePicker.Msg
    | SetEndDate DatePicker.Msg
    | ToggleIngredientCompletion Ingredient
    | UpdateNewGenealItem String
    | GeneralItemKeyDown Int


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        AddNewGeneralIngredient ->
            ( { model | newGeneralItemForm = NewGeneralItem { name = "" } }, Cmd.none )

        LoadedIngredientsForNewList (Ok response) ->
            ( { model
                | ingredients = response.groceryList
              }
            , Cmd.none
            )

        LoadedIngredientsForNewList (Err _) ->
            ( model, Cmd.none )

        GeneralItemKeyDown keyCode ->
            if keyCode == 13 then
                let
                    itemName =
                        case model.newGeneralItemForm of
                            NoNewItem ->
                                ""

                            NewGeneralItem item ->
                                item.name

                    groceryListId =
                        case model.currentGroceryList of
                            LoadedGroceryList groceryList ->
                                groceryList.id

                            _ ->
                                ""
                in
                ( { model | newGeneralItemForm = NoNewItem }, createGroceryListItem model.csrfToken groceryListId itemName )

            else
                ( model, Cmd.none )

        GroceryListItemCreated (Ok response) ->
            ( { model | currentGroceryList = LoadedGroceryList response }, Cmd.none )

        GroceryListItemCreated (Err msg) ->
            let
                _ =
                    Debug.log "message" msg
            in
            ( model, Cmd.none )

        GroceryListLoaded (Ok response) ->
            ( { model | currentGroceryList = LoadedGroceryList response }, Cmd.none )

        GroceryListLoaded (Err _) ->
            ( model, Cmd.none )

        GroceryListsLoaded (Ok response) ->
            ( { model
                | lists = response.lists
              }
            , Cmd.none
            )

        GroceryListsLoaded (Err _) ->
            ( model, Cmd.none )

        RemoveGroceryListItem itemId ->
            ( model, destroyGroceryListItem model.plannerId model.csrfToken itemId )

        SetEndDate msg ->
            let
                ( newDatePicker, datePickerFx, event ) =
                    DatePicker.update dateInputSettings msg model.endDatePicker

                ( newEndDate, newQueryEndDate, fetchCommand ) =
                    case event of
                        Changed formDate ->
                            case formDate of
                                Just date ->
                                    ( formDate
                                    , date
                                    , fetchIngredientsForTimeFrame model.plannerId model.queryStartDate date
                                    )

                                Nothing ->
                                    ( formDate, model.queryEndDate, Cmd.none )

                        NoChange ->
                            ( model.inputEndDate, model.queryEndDate, Cmd.none )
            in
            ( { model
                | inputEndDate = newEndDate
                , queryEndDate = newQueryEndDate
                , endDatePicker = newDatePicker
              }
            , fetchCommand
            )

        SetStartDate msg ->
            let
                ( newDatePicker, datePickerFx, event ) =
                    DatePicker.update dateInputSettings msg model.startDatePicker

                ( newStartDate, newQueryStartDate, fetchCommand ) =
                    case event of
                        Changed formDate ->
                            case formDate of
                                Just date ->
                                    ( formDate
                                    , date
                                    , fetchIngredientsForTimeFrame model.plannerId date model.queryEndDate
                                    )

                                Nothing ->
                                    ( formDate, model.queryStartDate, Cmd.none )

                        NoChange ->
                            ( model.inputStartDate, model.queryStartDate, Cmd.none )
            in
            ( { model
                | inputStartDate = newStartDate
                , queryStartDate = newQueryStartDate
                , startDatePicker = newDatePicker
              }
            , fetchCommand
            )

        ToggleIngredientCompletion ingredient ->
            let
                updatedIngredient =
                    { ingredient | isCompleted = not ingredient.isCompleted }

                updatedGroceryList =
                    case model.currentGroceryList of
                        LoadedGroceryList groceryList ->
                            LoadedGroceryList
                                { groceryList
                                    | mealIngredients =
                                        List.map
                                            (\i ->
                                                if i.id == ingredient.id then
                                                    updatedIngredient

                                                else
                                                    i
                                            )
                                            groceryList.mealIngredients
                                }

                        _ ->
                            model.currentGroceryList
            in
            ( { model | currentGroceryList = updatedGroceryList }
            , updateListIngredient updatedIngredient model.csrfToken
            )

        UpdateNewGenealItem name ->
            ( { model
                | newGeneralItemForm = NewGeneralItem { name = name }
              }
            , Cmd.none
            )

        None ->
            ( model, Cmd.none )


view : Model -> Html Message
view model =
    article [ class "clearfix flex w100" ]
        [ section [ class "bg-white col-6 rounded ml-auto p1" ]
            (case model.currentGroceryList of
                NewGroceryList ->
                    newGroceryListForm model

                LoadingGroceryList groceryList ->
                    [ span [] [ text "Loading..." ] ]

                LoadedGroceryList groceryList ->
                    groceryListForm model groceryList
            )
        , section [ class "col-3 pl2" ]
            [ ul [ class "bg-white rounded m0 p2" ]
                (List.map (groceryListItem model.plannerId model.currentGroceryList) model.lists)
            ]
        ]


newGroceryListForm : Model -> List (Html Message)
newGroceryListForm model =
    [ Html.header []
        [ Html.form
            [ action ("/planners/" ++ model.plannerId ++ "/grocery-lists")
            , class "flex items-center"
            , method "post"
            ]
            [ DatePicker.view model.inputStartDate
                { dateInputSettings | inputName = Just "start_date" }
                model.startDatePicker
                |> Html.map SetStartDate
            , DatePicker.view model.inputEndDate
                { dateInputSettings | inputName = Just "end_date" }
                model.endDatePicker
                |> Html.map SetEndDate
            , input [ name "authenticity_token", Html.Attributes.type_ "hidden", value model.csrfToken ] []
            , button [] [ text "Create Grocery List" ]
            ]
        ]
    , ul []
        (List.map ingredientItem model.ingredients)
    ]


groceryListForm : Model -> GroceryListResponse -> List (Html Message)
groceryListForm model groceryList =
    [ h3 [ class "center" ] [ text groceryList.name ]
    , Keyed.ul [ class "list-reset" ]
        (List.map groceryListIngredientItem groceryList.mealIngredients)
    , div [ class "flex items-center" ]
        [ h4 [ class "pr2" ] [ text "General" ]
        , a
            [ class "flex-center box2 circle bg-green c-white normal"
            , href "#"
            , onClickPreventDefault AddNewGeneralIngredient
            ]
            [ span [] [ text "+" ] ]
        ]
    , case model.newGeneralItemForm of
        NoNewItem ->
            span [] []

        NewGeneralItem item ->
            input [ onInput UpdateNewGenealItem, onKeyDown GeneralItemKeyDown, value item.name, class "input mt2" ] []
    ]


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Decode.map tagger keyCode)


groceryListIngredientItem : Ingredient -> ( String, Html Message )
groceryListIngredientItem ingredient =
    ( ingredient.id
    , li [ class "flex h5 ht3 items-center" ]
        [ input
            [ Html.Attributes.type_ "checkbox"
            , Html.Attributes.checked ingredient.isCompleted
            , onCheckBoxClick (ToggleIngredientCompletion ingredient)
            ]
            []
        , span [ class "ml1" ] [ text ingredient.name ]
        ]
    )


groceryListItem : String -> CurrentGroceryList -> GroceryList -> Html Message
groceryListItem plannerId currentGroceryList listItem =
    let
        currentGroceryListId =
            case currentGroceryList of
                LoadedGroceryList groceryList ->
                    groceryList.id

                _ ->
                    ""

        url =
            "/planners/" ++ plannerId ++ "/grocery-lists/" ++ listItem.id
    in
    li [ class "bg-grey flex ht3 items-center m0 mb1 p1 w100" ]
        [ a [ class "h5 text-decoration-none", href url ]
            [ text listItem.name ]
        , if currentGroceryListId == listItem.id then
            span [] []

          else
            a [ class "cursor ml-auto", onClick (RemoveGroceryListItem listItem.id) ] [ text "X" ]
        ]


onCheckBoxClick : message -> Attribute message
onCheckBoxClick message =
    let
        config =
            { stopPropagation = False
            , preventDefault = True
            }
    in
    onWithOptions "click" config (Decode.succeed message)


onClickPreventDefault : message -> Attribute message
onClickPreventDefault message =
    let
        config =
            { stopPropagation = False
            , preventDefault = True
            }
    in
    onWithOptions "click" config (Decode.succeed message)


ingredientItem : IngredientListItem -> Html Message
ingredientItem ingredient =
    li [] [ text ingredient.name ]



-- COMMANDS


destroyGroceryListItem : String -> String -> String -> Cmd Message
destroyGroceryListItem plannerId csrfToken listId =
    Http.send GroceryListsLoaded
        (Http.request
            { method = "DELETE"
            , headers = [ Http.header "X-CSRF-Token" csrfToken ]
            , url = "/api/planners/" ++ plannerId ++ "/grocery-lists/" ++ listId
            , body = Http.emptyBody
            , expect = Http.expectJson groceryListsDecoder
            , timeout = Nothing
            , withCredentials = False
            }
        )


createGroceryListItem : String -> String -> String -> Cmd Message
createGroceryListItem csrfToken listId itemName =
    Http.send GroceryListItemCreated
        (Http.request
            { method = "POST"
            , headers = [ Http.header "X-CSRF-Token" csrfToken ]
            , url = "/api/grocery-lists/" ++ listId ++ "/grocery-list-items"
            , body =
                Http.jsonBody
                    (Encode.object
                        [ ( "name", Encode.string itemName )
                        ]
                    )
            , expect = Http.expectJson groceryListDecoder
            , timeout = Nothing
            , withCredentials = False
            }
        )


fetchGroceryList : String -> String -> Cmd Message
fetchGroceryList plannerId listId =
    let
        urlString =
            "/api/planners/" ++ plannerId ++ "/grocery-lists/" ++ listId
    in
    Http.send GroceryListLoaded <|
        Http.get urlString groceryListDecoder


fetchIngredientsForTimeFrame : String -> Date -> Date -> Cmd Message
fetchIngredientsForTimeFrame plannerId startDate endDate =
    let
        urlString =
            "/api/planners/"
                ++ plannerId
                ++ "/grocery-lists/new"
                ++ "?start_date="
                ++ DateFormat.toIsoString startDate
                ++ "&end_date="
                ++ DateFormat.toIsoString endDate
    in
    Http.send LoadedIngredientsForNewList <|
        Http.get urlString ingredientsListDecoder


fetchGroceryLists : String -> Cmd Message
fetchGroceryLists plannerId =
    let
        urlString =
            "/api/planners/" ++ plannerId ++ "/grocery-lists"
    in
    Http.send GroceryListsLoaded <|
        Http.get urlString groceryListsDecoder


updateListIngredient : Ingredient -> String -> Cmd Message
updateListIngredient ingredient csrfToken =
    let
        urlString =
            "/api/grocery-list-items/" ++ ingredient.id
    in
    Http.send GroceryListLoaded <|
        Http.request
            { method = "PATCH"
            , headers = [ Http.header "X-CSRF-Token" csrfToken ]
            , url = urlString
            , body =
                Http.jsonBody
                    (Encode.object
                        [ ( "name", Encode.string ingredient.name )
                        , ( "is_completed", Encode.bool ingredient.isCompleted )
                        ]
                    )
            , expect = Http.expectJson groceryListDecoder
            , timeout = Nothing
            , withCredentials = False
            }



-- DECODERS


ingredientsListDecoder : Decode.Decoder IngredientListResponse
ingredientsListDecoder =
    Decode.map2 IngredientListResponse
        (Decode.field "grocery_list"
            (Decode.list
                (Decode.map IngredientListItem <|
                    Decode.field "name" Decode.string
                )
            )
        )
        (Decode.field "mealbook"
            (Decode.map Mealbook
                (Decode.field "id" Decode.string)
            )
        )


groceryListItemDecoder : Decode.Decoder (List Ingredient)
groceryListItemDecoder =
    Decode.list
        (Decode.map3 Ingredient
            (Decode.field "is_completed" Decode.bool)
            (Decode.field "id" Decode.string)
            (Decode.field "edited_name" Decode.string)
        )


groceryListDecoder : Decode.Decoder GroceryListResponse
groceryListDecoder =
    Decode.field "grocery_list"
        (Decode.map3 GroceryListResponse
            (Decode.field "id" Decode.string)
            (Decode.field "name" Decode.string)
            (Decode.field "grocery_list_items" groceryListItemDecoder)
        )


groceryListsDecoder : Decode.Decoder GroceryListsResponse
groceryListsDecoder =
    Decode.map GroceryListsResponse
        (Decode.list
            (Decode.map2 GroceryList
                (Decode.field "id" Decode.string)
                (Decode.field "name" Decode.string)
            )
        )


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none



-- MAIN


init : Flags -> ( Model, Cmd Message )
init flags =
    let
        startDate =
            DateFormat.fromIsoString flags.initStartDate |> Maybe.withDefault (Date.fromTime 0)

        endDate =
            DateFormat.fromIsoString flags.initEndDate |> Maybe.withDefault (Date.fromTime 0)

        currentGroceryList =
            case flags.listId of
                Just id ->
                    LoadingGroceryList (GroceryList id "Hello")

                Nothing ->
                    NewGroceryList
    in
    ( { csrfToken = flags.csrfToken
      , currentGroceryList = currentGroceryList
      , ingredients = []
      , inputStartDate = Just startDate
      , inputEndDate = Just endDate
      , lists = []
      , newGeneralItemForm = NoNewItem
      , plannerId = flags.plannerId
      , queryStartDate = startDate
      , queryEndDate = endDate
      , startDatePicker = DatePicker.initFromDate startDate
      , endDatePicker = DatePicker.initFromDate endDate
      }
    , Cmd.batch
        [ case flags.listId of
            Just id ->
                fetchGroceryList flags.plannerId id

            Nothing ->
                fetchIngredientsForTimeFrame flags.plannerId startDate endDate
        , fetchGroceryLists flags.plannerId
        ]
    )


main : Program Flags Model Message
main =
    Html.programWithFlags
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
