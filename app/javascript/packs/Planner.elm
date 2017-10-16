module Planner exposing (..)

import Http
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (class, classList, draggable, href, placeholder, value)
import Json.Decode as Decode
import Json.Encode as Encode


-- MODEL


type alias Planner =
    { currentWeekDateLabel : String
    , id : String
    , meals : List Meal
    , nextWeekDate : String
    , prevWeekDate : String
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
    { mealType : String }


type WeekdayMeal
    = Assigned AssignedMeal
    | Unassigned UnassignedMeal


type alias Weekday =
    { date : String
    , title : String
    , meals : List WeekdayMeal
    }


type alias Model =
    { appError : Maybe String
    , csrfToken : String
    , currentWeekDate : String
    , currentWeekDateLabel : String
    , isLoadingMeals : Bool
    , isDraggingMealId : Maybe String
    , mealbookId : String
    , meals : List Meal
    , newMealText : String
    , nextWeekDate : String
    , prevWeekDate : String
    , weekdayAssignments : List Weekday
    }


type alias Flags =
    { csrfToken : String
    , currentWeekDate : String
    , mealbookId : String
    , prevWeekDate : String
    }



-- INIT


init : Flags -> ( Model, Cmd Message )
init flags =
    ( { appError = Nothing
      , csrfToken = flags.csrfToken
      , currentWeekDate = flags.currentWeekDate
      , currentWeekDateLabel = ""
      , isLoadingMeals = True
      , isDraggingMealId = Nothing
      , newMealText = ""
      , mealbookId = flags.mealbookId
      , meals = []
      , nextWeekDate = ""
      , prevWeekDate = ""
      , weekdayAssignments = []
      }
    , fetchPlanner flags.mealbookId flags.currentWeekDate
    )


fetchPlanner : String -> String -> Cmd Message
fetchPlanner mealbookId weekDate =
    let
        urlString =
            "/api/planners/" ++ mealbookId ++ "?weekdate=" ++ weekDate
    in
        Http.send LoadedPlanner
            (Http.get urlString plannerDecoder)


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


postAssignedMeal : Maybe String -> String -> Int -> String -> Cmd Message
postAssignedMeal mealId mealbookId position date =
    let
        mealIdString =
            case mealId of
                Nothing ->
                    ""

                Just mealId ->
                    mealId
    in
        Http.send LoadedPlanner
            (Http.post
                "/api/meal-assignments"
                (Http.jsonBody
                    (Encode.object
                        [ ( "meal_id", Encode.string mealIdString )
                        , ( "mealbook_id", Encode.string mealbookId )
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
        (Decode.map6 Planner
            (Decode.field "current_date_short" Decode.string)
            (Decode.field "id" Decode.string)
            (Decode.field "meals" mealsDecoder)
            (Decode.field "next_week" Decode.string)
            (Decode.field "prev_week" Decode.string)
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
            [ Decode.map Unassigned <|
                Decode.map UnassignedMeal
                    (Decode.field "mealType" Decode.string)
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
        [ navigationHeader model
        , div [ class "flex flex-auto main" ]
            [ div [ class "bg-light-gray flex flex-column flex-auto px1 scroll-y" ]
                [ section [ class "flex flex-center ht4" ]
                    [ div
                        [ class "box1 chevron-circle-left cursor"
                        , onClick (LoadPlanner model.prevWeekDate)
                        ]
                        []
                    , div [ class "px1" ] [ text model.currentWeekDateLabel ]
                    , div
                        [ class "box1 chevron-circle-right cursor"
                        , onClick (LoadPlanner model.nextWeekDate)
                        ]
                        []
                    ]
                , div [ class "weekday-meals px1 pb2 flex flex-column flex-1" ]
                    (case model.appError of
                        Nothing ->
                            (List.map (weekdayDayListDay model.isDraggingMealId) model.weekdayAssignments)

                        Just error ->
                            [ text error ]
                    )
                ]
            , div [ class "main-meals pa2 w5" ]
                [ input
                    [ class "input"
                    , placeholder "Enter New Meal"
                    , value model.newMealText
                    , onEnter AddNewMeal
                    , onInput UpdateNewMealText
                    ]
                    []
                , div []
                    [ if model.isLoadingMeals then
                        div [] [ text "Is Loading" ]
                      else
                        div [] [ text "" ]
                    ]
                , div [ class "py1" ]
                    (List.map mealListMeal model.meals)
                ]
            ]
        ]


navigationHeader : Model -> Html Message
navigationHeader model =
    nav [ class "flex items-center ht4 px2" ]
        [ h3 []
            [ a [ class "normal", href "/" ] [ text "Mealbook Planners" ] ]
        , span [ class "m-auto" ] [ text "Header" ]
        , a
            [ class "flex-center box2 circle bg-green c-white normal"
            , href ("/mealbooks/" ++ model.mealbookId ++ "/meals/new")
            ]
            [ text "+" ]
        ]


weekdayDayListDay : Maybe String -> Weekday -> Html Message
weekdayDayListDay mealId weekday =
    div [ class "weekday bg-white flex flex-auto m-ht5 p1 mb2 relative rounded" ]
        [ div [ class "flex flex-auto" ]
            [ div [ class "flex flex-column flex-center w6" ]
                [ h4 [ class "font1 ma0" ] [ text weekday.title ]
                , h6 [] [ text weekday.date ]
                ]
            , div
                [ class "flex-auto flex" ]
                (List.indexedMap
                    (weekdayAssignment mealId weekday)
                    weekday.meals
                )
            ]
        ]


weekdayAssignment : Maybe String -> Weekday -> Int -> WeekdayMeal -> Html Message
weekdayAssignment draggingMealId weekday position meal =
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

        Unassigned emptyAssignment ->
            let
                isDraggingMeal =
                    case draggingMealId of
                        Nothing ->
                            False

                        Just _ ->
                            True
            in
                div
                    [ classList
                        [ ( "flex flex-33 flex-auto ml2", True )
                        , ( "border-dashed", isDraggingMeal )
                        ]
                    , onDragEnter (MealEnteredWeekday weekday.date)
                    , onDragOver
                    , onDrop (MealDropped position weekday.date)
                    ]
                    [ span [ class "font0875 m-auto" ]
                        [ if isDraggingMeal then
                            text emptyAssignment.mealType
                          else
                            text ""
                        ]
                    ]


mealListMeal : Meal -> Html Message
mealListMeal meal =
    div
        [ draggable "true"
        , onDragStart (StartDraggingMeal meal.id)
        , onDragEnd EndDraggingMeal
        , class "flex bg-white font0875 hand ht4 items-center justify-between mb1 p1 rounded"
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
    | LoadPlanner String
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
            ( model, postAssignedMeal model.isDraggingMealId model.mealbookId position date )

        StartDraggingMeal id ->
            ( { model | isDraggingMealId = Just id }, Cmd.none )

        EndDraggingMeal ->
            ( { model | isDraggingMealId = Nothing }, Cmd.none )

        UpdateNewMealText text ->
            ( { model | newMealText = text }, Cmd.none )

        LoadPlanner weekDate ->
            ( model, fetchPlanner model.mealbookId weekDate )

        LoadedPlanner (Ok planner) ->
            ( { model
                | currentWeekDateLabel = planner.currentWeekDateLabel
                , isLoadingMeals = False
                , meals = planner.meals
                , nextWeekDate = planner.nextWeekDate
                , prevWeekDate = planner.prevWeekDate
                , weekdayAssignments = planner.weekdays
              }
            , Cmd.none
            )

        LoadedPlanner (Err _) ->
            ( { model
                | isLoadingMeals = False
                , appError = Just "Oops something went wrong, please refresh the page"
              }
            , Cmd.none
            )

        RemoveAssignment assignmentId ->
            ( model, destroyAssignedMeal assignmentId )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none



-- MAIN


main : Program Flags Model Message
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
