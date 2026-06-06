Config = {}

-- Command to open to-do list
Config.Command = 'todo'

-- Item name (optional - set to nil to disable item usage)
Config.TodoItem = 'notebook'

-- Database table name
Config.DatabaseTable = 'player_todos'

-- Notifications enabled
Config.Notifications = true

-- Max todos per player
Config.MaxTodos = 100

-- Auto-delete completed todos after X days (0 to disable)
Config.AutoDeleteDays = 0

-- Priority levels
Config.Priorities = {
    'Low',
    'Medium',
    'High',
    'Urgent'
}

-- Default priority
Config.DefaultPriority = 'Medium'

-- Enable due dates
Config.EnableDueDates = true

-- Enable categories
Config.EnableCategories = true

-- Todo categories
Config.Categories = {
    'Work',
    'Personal',
    'Shopping',
    'Health',
    'Home',
    'Other'
}

-- Notifications settings
Config.NotificationSettings = {
    AddSuccess = 'Task added successfully',
    DeleteSuccess = 'Task deleted',
    UpdateSuccess = 'Task updated',
    ClearSuccess = 'Tasks cleared',
    ErrorOccurred = 'An error occurred'
}

-- Maximum characters for task text
Config.MaxTaskLength = 255