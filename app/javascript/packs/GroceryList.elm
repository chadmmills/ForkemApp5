module GroceryList exposing (..)

import Http exposing (..)
import Html exposing (..)


-- import Html.Attributes exposing (..)

import Json.Decode as Decode
import Date exposing (Date)
import Date.Extra as DateFormat
import DatePicker exposing (defaultSettings, DateEvent(..))


-- import Html.Events exposing (..)

import Html.Attributes exposing (class, classList, href, placeholder, value)


type alias Flags =
    { csrfToken : String
    , initEndDate : String
    , initStartDate : String
    , plannerId : String
    }


type alias Ingredient =
    { name : String
    }


type alias Mealbook =
    { id : String }


type alias GroceryList =
    { id : String }


type alias GroceryListResponse =
    { groceryList : List Ingredient
    , mealbook : Mealbook
    }


type alias Model =
    { ingredients : List Ingredient
    , inputStartDate : Maybe Date
    , inputEndDate : Maybe Date
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
    | LoadedGroceryList (Result Http.Error GroceryListResponse)
    | SetStartDate DatePicker.Msg
    | SetEndDate DatePicker.Msg


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        LoadedGroceryList (Ok response) ->
            ( { model
                | ingredients = response.groceryList
              }
            , Cmd.none
            )

        LoadedGroceryList (Err _) ->
            ( model, Cmd.none )

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
                                    , fetchGroceryList model.plannerId model.queryStartDate date
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
                                    , fetchGroceryList model.plannerId date model.queryEndDate
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

        None ->
            ( model, Cmd.none )


view : Model -> Html Message
view model =
    section [ class "bg-white rounded mt2 mx-auto mx-w-48 p1 w100" ]
        [ Html.header [ class "flex items-center" ]
            [ DatePicker.view model.inputStartDate
                dateInputSettings
                model.startDatePicker
                |> Html.map SetStartDate
            , DatePicker.view model.inputEndDate
                dateInputSettings
                model.endDatePicker
                |> Html.map SetEndDate
            , button [] [ text "Create Grocery List" ]
            ]
        , ul []
            (List.map ingredientItem model.ingredients)
        ]


ingredientItem : Ingredient -> Html Message
ingredientItem ingredient =
    li [] [ text ingredient.name ]



-- COMMANDS


fetchGroceryList : String -> Date -> Date -> Cmd Message
fetchGroceryList plannerId startDate endDate =
    let
        urlString =
            "/api/planners/"
                ++ plannerId
                ++ "/grocery-list"
                ++ "?start_date="
                ++ DateFormat.toIsoString startDate
                ++ "&end_date="
                ++ DateFormat.toIsoString endDate
    in
        Http.send LoadedGroceryList <|
            Http.get urlString groceryListDecoder



-- DECODERS


groceryListDecoder : Decode.Decoder GroceryListResponse
groceryListDecoder =
    Decode.map2 GroceryListResponse
        (Decode.field "grocery_list"
            (Decode.list
                (Decode.map Ingredient <|
                    Decode.field "name" Decode.string
                )
            )
        )
        (Decode.field "mealbook" <|
            Decode.map GroceryList <|
                Decode.field "id" Decode.string
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
    in
        ( { ingredients = []
          , inputStartDate = Just startDate
          , inputEndDate = Just endDate
          , plannerId = flags.plannerId
          , queryStartDate = startDate
          , queryEndDate = endDate
          , startDatePicker = DatePicker.initFromDate startDate
          , endDatePicker = DatePicker.initFromDate endDate
          }
        , fetchGroceryList flags.plannerId startDate endDate
        )


main : Program Flags Model Message
main =
    Html.programWithFlags
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
