flowchart TB
    %% Main App Structure
    App[App Root] --> Router[App Router]
    Router --> AuthScreens[Auth Screens]
    Router --> MainScreens[Main App Screens]
    
    %% Main Screen Breakdown
    MainScreens --> HomeScreen[Home Dashboard]
    MainScreens --> CategoryScreen[Category Views]
    MainScreens --> EntityScreen[Entity Management]
    MainScreens --> TaskScreen[Task Management]
    MainScreens --> SettingsScreen[Settings]
    
    %% State Management Layer
    StateLayer[Riverpod Providers] --> AuthProvider[Auth Provider]
    StateLayer[Riverpod Providers] --> CategoriesProvider[Categories Provider]
    StateLayer[Riverpod Providers] --> EntitiesProvider[Entities Provider]
    StateLayer[Riverpod Providers] --> TasksProvider[Tasks Provider]
    StateLayer[Riverpod Providers] --> SettingsProvider[Settings Provider]
    
    %% Data Layer
    DataLayer[Repository Layer] --> AuthRepo[Auth Repository]
    DataLayer[Repository Layer] --> CategoryRepo[Category Repository]
    DataLayer[Repository Layer] --> EntityRepo[Entity Repository]
    DataLayer[Repository Layer] --> TaskRepo[Task Repository]
    DataLayer[Repository Layer] --> NotificationRepo[Notification Repository]
    
    %% Supabase Services
    SupabaseClient[Supabase Client] --> Auth[Auth Service]
    SupabaseClient[Supabase Client] --> Database[PostgreSQL Database]
    SupabaseClient[Supabase Client] --> Storage[Storage Buckets]
    SupabaseClient[Supabase Client] --> EdgeFunctions[Edge Functions]
    SupabaseClient[Supabase Client] --> Realtime[Realtime Subscriptions]
    
    %% Connections between layers
    AuthScreens <--> AuthProvider
    MainScreens <--> StateLayer
    
    AuthProvider <--> AuthRepo
    CategoriesProvider <--> CategoryRepo
    EntitiesProvider <--> EntityRepo
    TasksProvider <--> TaskRepo
    SettingsProvider <--> DataLayer
    
    DataLayer <--> SupabaseClient
    
    %% Database Tables
    Database --> UsersTable[Users & Profiles]
    Database --> CategoriesTable[Categories]
    Database --> EntitiesTable[Entities]
    Database --> TasksTable[Tasks & Scheduling]
    Database --> ReferencesTable[References]
    
    %% Key Features
    subgraph "Key Features"
        PolymorphicEntities[Polymorphic Entity System]
        TaskScheduling[Task Scheduling]
        FamilySharing[Family Sharing]
        Notifications[Real-time Notifications]
        CalendarSync[Calendar Integration]
    end
    
    %% Connect features to implementation
    EntitiesProvider --- PolymorphicEntities
    TasksProvider --- TaskScheduling
    AuthProvider --- FamilySharing
    Realtime --- Notifications
    EdgeFunctions --- CalendarSync

    %% Style definitions
    classDef uiLayer fill:#de953e,color:white,stroke:#333,stroke-width:1px
    classDef stateLayer fill:#4672b4,color:white,stroke:#333,stroke-width:1px
    classDef dataLayer fill:#47956f,color:white,stroke:#333,stroke-width:1px
    classDef supabaseLayer fill:#8b251e,color:white,stroke:#333,stroke-width:1px
    classDef featureLayer fill:#6b4c9a,color:white,stroke:#333,stroke-width:1px
    
    %% Apply styles
    class App,Router,AuthScreens,MainScreens,HomeScreen,CategoryScreen,EntityScreen,TaskScreen,SettingsScreen uiLayer
    class StateLayer,AuthProvider,CategoriesProvider,EntitiesProvider,TasksProvider,SettingsProvider stateLayer
    class DataLayer,AuthRepo,CategoryRepo,EntityRepo,TaskRepo,NotificationRepo dataLayer
    class SupabaseClient,Auth,Database,Storage,EdgeFunctions,Realtime,UsersTable,CategoriesTable,EntitiesTable,TasksTable,ReferencesTable supabaseLayer
    class PolymorphicEntities,TaskScheduling,FamilySharing,Notifications,CalendarSync featureLayer
