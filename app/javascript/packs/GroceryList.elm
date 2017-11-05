module GroceryList exposing (..)

import Http exposing (..)
import Html exposing (..)


-- import Html.Attributes exposing (..)

import Json.Decode as Decode
import Date exposing (Date)
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
    , listStartDate : Maybe Date
    , listEndDate : Maybe Date
    , startDatePicker : DatePicker.DatePicker
    , endDatePicker : DatePicker.DatePicker
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
                    DatePicker.update defaultSettings msg model.endDatePicker
            in
                ( { model
                    | listEndDate =
                        case event of
                            Changed date ->
                                date

                            NoChange ->
                                model.listEndDate
                    , endDatePicker = newDatePicker
                  }
                , Cmd.none
                )

        SetStartDate msg ->
            let
                ( newDatePicker, datePickerFx, event ) =
                    DatePicker.update defaultSettings msg model.startDatePicker
            in
                ( { model
                    | listStartDate =
                        case event of
                            Changed date ->
                                date

                            NoChange ->
                                model.listStartDate
                    , startDatePicker = newDatePicker
                  }
                , Cmd.none
                )

        None ->
            ( model, Cmd.none )


view : Model -> Html Message
view model =
    section []
        [ Html.header [ class "flex" ]
            [ DatePicker.view model.listStartDate
                defaultSettings
                model.startDatePicker
                |> Html.map SetStartDate
            , DatePicker.view model.listEndDate
                defaultSettings
                model.endDatePicker
                |> Html.map SetEndDate
            ]
        , ul []
            (List.map ingredientItem model.ingredients)
        ]


ingredientItem : Ingredient -> Html Message
ingredientItem ingredient =
    li [] [ text ingredient.name ]



-- COMMANDS


fetchGroceryList : String -> Cmd Message
fetchGroceryList plannerId =
    let
        urlString =
            "/api/planners/"
                ++ plannerId
                ++ "/grocery-list"
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
-- DatePicker.initFromDate (Date.fromString "1969-07-20" |> Result.toMaybe |> Maybe.withDefault (Date.fromTime 0))


init : Flags -> ( Model, Cmd Message )
init flags =
    let
        -- ( startDatePicker, startDatePickerFx ) =
        --     DatePicker.init
        startDate =
            (Date.fromString flags.initStartDate |> Result.toMaybe |> Maybe.withDefault (Date.fromTime 0))

        endDate =
            (Date.fromString flags.initEndDate |> Result.toMaybe |> Maybe.withDefault (Date.fromTime 0))
    in
        ( { ingredients = []
          , listStartDate = Just startDate
          , listEndDate = Just endDate
          , startDatePicker = DatePicker.initFromDate startDate
          , endDatePicker = DatePicker.initFromDate endDate
          }
        , Cmd.batch
            [ fetchGroceryList flags.plannerId
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
