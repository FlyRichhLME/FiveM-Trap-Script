local QBCore = exports['qb-core']:GetCoreObject()

local todoOpen = false

-- Notify function
local function Notify(msg, type)
    if not Config.Notifications then return end
    QBCore.Functions.Notify(msg, type or 'primary')
end

-- Open to-do list
local function OpenTodoApp()
    if todoOpen then return end
    
    todoOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        config = {
            priorities = Config.Priorities,
            categories = Config.Categories,
            enableDueDates = Config.EnableDueDates,
            enableCategories = Config.EnableCategories,
            maxTaskLength = Config.MaxTaskLength
        }
    })
    
    -- Request todos from server
    QBCore.Functions.TriggerCallback('qb-todo:server:GetTodos', function(todos)
        SendNUIMessage({
            action = 'loadTodos',
            todos = todos or {}
        })
    end)
end

-- Close to-do list
local function CloseTodoApp()
    todoOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

-- Close on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if todoOpen then
            CloseTodoApp()
        end
    end
end)

-- Escape key to close
RegisterKeyMapping('closeui', 'Close UI', 'keyboard', 'ESCAPE')
RegisterCommand('+closeui', function()
    if todoOpen then
        CloseTodoApp()
    end
end, false)

-- Register command to open to-do
RegisterCommand(Config.Command, function()
    OpenTodoApp()
end, false)

-- Register item usage (if enabled)
if Config.TodoItem and Config.TodoItem ~= '' then
    QBCore.Functions.CreateUseableItem(Config.TodoItem, function(source)
        TriggerEvent('qb-todo:client:OpenTodo')
    end)
end

RegisterNetEvent('qb-todo:client:OpenTodo', function()
    OpenTodoApp()
end)

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    CloseTodoApp()
    cb('ok')
end)

RegisterNUICallback('addTodo', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-todo:server:AddTodo', function(success, todo)
        if success then
            Notify(Config.NotificationSettings.AddSuccess, 'success')
            cb({ success = true, todo = todo })
        else
            Notify(Config.NotificationSettings.ErrorOccurred, 'error')
            cb({ success = false })
        end
    end, data.text, data.priority, data.category, data.dueDate)
end)

RegisterNUICallback('toggleTodo', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-todo:server:ToggleTodo', function(success)
        if success then
            cb({ success = true })
        else
            Notify(Config.NotificationSettings.ErrorOccurred, 'error')
            cb({ success = false })
        end
    end, data.id)
end)

RegisterNUICallback('updateTodo', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-todo:server:UpdateTodo', function(success)
        if success then
            Notify(Config.NotificationSettings.UpdateSuccess, 'success')
            cb({ success = true })
        else
            Notify(Config.NotificationSettings.ErrorOccurred, 'error')
            cb({ success = false })
        end
    end, data.id, data.priority, data.category, data.dueDate)
end)

RegisterNUICallback('deleteTodo', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-todo:server:DeleteTodo', function(success)
        if success then
            Notify(Config.NotificationSettings.DeleteSuccess, 'success')
            cb({ success = true })
        else
            Notify(Config.NotificationSettings.ErrorOccurred, 'error')
            cb({ success = false })
        end
    end, data.id)
end)

RegisterNUICallback('clearCompleted', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-todo:server:ClearCompleted', function(success, count)
        if success then
            Notify(Config.NotificationSettings.ClearSuccess .. ' (' .. count .. ')', 'success')
            cb({ success = true, count = count })
        else
            Notify(Config.NotificationSettings.ErrorOccurred, 'error')
            cb({ success = false })
        end
    end)
end)

RegisterNUICallback('clearAll', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-todo:server:ClearAll', function(success, count)
        if success then
            Notify(Config.NotificationSettings.ClearSuccess .. ' (' .. count .. ')', 'success')
            cb({ success = true, count = count })
        else
            Notify(Config.NotificationSettings.ErrorOccurred, 'error')
            cb({ success = false })
        end
    end)
end)

print('^2[qb-todo]^7 Client loaded successfully')