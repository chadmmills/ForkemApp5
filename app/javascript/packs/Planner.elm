module Planner exposing (..)

import Http
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (class, draggable, placeholder, value)
import Json.Decode as Decode
import Json.Encode as Encode


-- MODEL


type alias Planner =
    { id : String
    , meals : List Meal
    , weekdays : List Weekday
    }


type alias Meal =
    { id : String
    , name : String
    }


type alias AssignedMeal =
    { assignmentId : String
    , id : String
    , name : String
    , position : Int
    }


type alias UnassignedMeal =
    {}


type WeekdayMeal
    = Assigned AssignedMeal
    | Unassigned UnassignedMeal


type alias Weekday =
    { date : String
    , title : String
    , meals : List WeekdayMeal
    }


type alias Model =
    { isLoadingMeals : Bool
    , isDraggingMealId : Maybe String
    , mealbookId : Maybe String
    , meals : List Meal
    , newMealText : String
    , weekdayAssignments : List Weekday
    }



-- INIT


init : ( Model, Cmd Message )
init =
    ( { isLoadingMeals = True
      , isDraggingMealId = Just "FakeId"
      , newMealText = ""
      , mealbookId = Nothing
      , meals = []
      , weekdayAssignments = []
      }
    , fetchPlanner
    )


fetchPlanner : Cmd Message
fetchPlanner =
    Http.send LoadedPlanner
        (Http.get "/api/planners" plannerDecoder)


destroyAssignedMeal : String -> Cmd Message
destroyAssignedMeal assignmentId =
    Http.send LoadedPlanner
        (Http.request
            { method = "DELETE"
            , headers = []
            , url = "/api/meal-assignments/" ++ assignmentId
            , body = Http.emptyBody
            , expect = Http.expectJson plannerDecoder
            , timeout = Nothing
            , withCredentials = False
            }
        )


postAssignedMeal : Maybe String -> Maybe String -> Int -> String -> Cmd Message
postAssignedMeal mealId mealbookId position date =
    let
        mealIdString =
            case mealId of
                Nothing ->
                    ""

                Just mealId ->
                    mealId

        mealbookIdString =
            case mealbookId of
                Nothing ->
                    ""

                Just mealbookId ->
                    mealbookId
    in
        Http.send LoadedPlanner
            (Http.post
                "/api/meal-assignments"
                (Http.jsonBody
                    (Encode.object
                        [ ( "meal_id", Encode.string mealIdString )
                        , ( "mealbook_id", Encode.string mealbookIdString )
                        , ( "weekdate", Encode.string date )
                        , ( "position", Encode.int position )
                        ]
                    )
                )
                plannerDecoder
            )


plannerDecoder : Decode.Decoder Planner
plannerDecoder =
    Decode.field "mealbook"
        (Decode.map3 Planner
            (Decode.field "id" Decode.string)
            (Decode.field "meals" mealsDecoder)
            (Decode.field "weekdays" weekdaysDecoder)
        )


weekdaysDecoder : Decode.Decoder (List Weekday)
weekdaysDecoder =
    Decode.list
        (Decode.map3 Weekday
            (Decode.field "date" Decode.string)
            (Decode.field "title" Decode.string)
            (Decode.field "meals" weekdayMealsDecoder)
        )


weekdayMealsDecoder : Decode.Decoder (List WeekdayMeal)
weekdayMealsDecoder =
    Decode.list
        (Decode.oneOf
            [ Decode.null (Unassigned {})
            , Decode.map Assigned <|
                Decode.map4 AssignedMeal
                    (Decode.field "assignment_id" Decode.string)
                    (Decode.field "id" Decode.string)
                    (Decode.field "name" Decode.string)
                    (Decode.field "position" Decode.int)
            ]
        )


mealsDecoder : Decode.Decoder (List Meal)
mealsDecoder =
    Decode.list mealDecoder


mealDecoder : Decode.Decoder Meal
mealDecoder =
    Decode.map2 Meal
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)



-- VIEW


view : Model -> Html Message
view model =
    div [ class "flex flex-column vh-100" ]
        [ nav [ class "flex items-center ht4" ] [ text "Header" ]
        , div [ class "flex flex-auto main" ]
            [ div [ class "bg-light-gray flex-auto px1 py2 scroll-y" ]
                [ div [ class "weekday-meals px1 pb2 flex flex-column flex-1" ]
                    (List.map (weekdayDayListDay model.isDraggingMealId) model.weekdayAssignments)
                ]
            , div [ class "main-meals pa2 w5" ]
                [ input
                    [ placeholder "Enter New Meal"
                    , value model.newMealText
                    , onEnter AddNewMeal
                    , onInput UpdateNewMealText
                    ]
                    []
                , div [] [ text "Planner Meals" ]
                , div []
                    [ if model.isLoadingMeals then
                        div [] [ text "Is Loading" ]
                      else
                        div [] [ text "" ]
                    ]
                , div []
                    (List.map mealListMeal model.meals)
                ]
            ]
        ]


weekdayDayListDay : Maybe String -> Weekday -> Html Message
weekdayDayListDay mealId weekday =
    div [ class "weekday bg-white flex flex-auto ht8 p1 mb2 relative rounded" ]
        [ div [ class "flex flex-auto" ]
            [ div [ class "flex flex-column flex-center w6" ]
                [ h4 [ class "font1 ma0" ] [ text weekday.title ]
                , h6 [] [ text weekday.date ]
                ]
            , div
                [ class "flex-auto flex" ]
                (List.indexedMap
                    (weekdayAssignment weekday)
                    weekday.meals
                )
            ]
        ]


weekdayAssignment : Weekday -> Int -> WeekdayMeal -> Html Message
weekdayAssignment weekday position meal =
    case meal of
        Assigned assignedMeal ->
            div [ class "bg-grey flex flex-33 hover ml2 p1 rounded relative" ]
                [ div
                    [ class "box2 cursor flex-center hover-reveal-flex top-right"
                    , onClick (RemoveAssignment assignedMeal.assignmentId)
                    ]
                    [ text "×" ]
                , h5 [ class "m-auto" ] [ text assignedMeal.name ]
                ]

        Unassigned _ ->
            div
                [ class "border-dashed flex-33 flex-auto ml2"
                , onDragEnter (MealEnteredWeekday weekday.date)
                , onDragOver
                , onDrop (MealDropped position weekday.date)
                ]
                []


mealListMeal : Meal -> Html Message
mealListMeal meal =
    div
        [ draggable "true"
        , onDragStart (StartDraggingMeal meal.id)
        , onDragEnd EndDraggingMeal
        , class "flex bg-white ht4 items-center justify-between mb1 p1 rounded"
        ]
        [ text meal.name ]


isDragging : Maybe String -> Bool
isDragging mealId =
    case mealId of
        Nothing ->
            False

        Just mealId ->
            True


onDrop : Message -> Attribute Message
onDrop msg =
    onWithOptions "drop" { stopPropagation = True, preventDefault = True } (Decode.succeed msg)


onDragOver : Attribute Message
onDragOver =
    onWithOptions "dragover" { stopPropagation = True, preventDefault = True } (Decode.succeed None)


onDragEnter : Message -> Attribute Message
onDragEnter msg =
    onWithOptions "dragenter" { stopPropagation = True, preventDefault = True } (Decode.succeed msg)


onDragEnd : Message -> Attribute Message
onDragEnd msg =
    on "dragend" (Decode.succeed msg)


onDragStart : Message -> Attribute Message
onDragStart msg =
    on
        "dragstart"
        (Decode.succeed msg)


onEnter : Message -> Attribute Message
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Decode.succeed msg
            else
                Decode.fail "not ENTER"
    in
        on "keydown" (Decode.andThen isEnter keyCode)



-- MESSAGE


type Message
    = None
    | AddNewMeal
    | EndDraggingMeal
    | LoadedPlanner (Result Http.Error Planner)
    | MealDropped Int String
    | MealEnteredWeekday String
    | RemoveAssignment String
    | StartDraggingMeal String
    | UpdateNewMealText String



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        None ->
            ( model, Cmd.none )

        AddNewMeal ->
            ( { model
                | newMealText = ""
                , meals =
                    if String.isEmpty model.newMealText then
                        model.meals
                    else
                        model.meals ++ [ { id = "abc", name = model.newMealText } ]
              }
            , Cmd.none
            )

        MealEnteredWeekday date ->
            ( model, Cmd.none )

        MealDropped position date ->
            Debug.log (toString position)
                Debug.log
                date
                ( model, postAssignedMeal model.isDraggingMealId model.mealbookId position date )

        StartDraggingMeal id ->
            ( { model | isDraggingMealId = Just id }, Cmd.none )

        EndDraggingMeal ->
            ( { model | isDraggingMealId = Nothing }, Cmd.none )

        UpdateNewMealText text ->
            ( { model | newMealText = text }, Cmd.none )

        LoadedPlanner (Ok planner) ->
            ( { model
                | isLoadingMeals = False
                , mealbookId = Just planner.id
                , meals = planner.meals
                , weekdayAssignments = planner.weekdays
              }
            , Cmd.none
            )

        LoadedPlanner (Err _) ->
            Debug.log "Error Loading Planner"
                ( { model | isLoadingMeals = False }, Cmd.none )

        RemoveAssignment assignmentId ->
            ( model, destroyAssignedMeal assignmentId )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none



-- MAIN


main : Program Never Model Message
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
