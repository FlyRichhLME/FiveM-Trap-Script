local QBCore = exports['qb-core']:GetCoreObject()

-- Initialize database table on resource start
local function InitDatabase()
    local CreateTableQuery = [[
        CREATE TABLE IF NOT EXISTS `]] .. Config.DatabaseTable .. [[` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `citizenid` varchar(50) NOT NULL,
            `todo_id` varchar(50) NOT NULL,
            `text` longtext NOT NULL,
            `priority` varchar(20) DEFAULT 'Medium',
            `category` varchar(50) DEFAULT 'Other',
            `due_date` datetime,
            `completed` tinyint(1) DEFAULT 0,
            `completed_at` datetime,
            `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
            `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `unique_todo` (`citizenid`, `todo_id`),
            INDEX `idx_citizenid` (`citizenid`),
            INDEX `idx_completed` (`completed`),
            INDEX `idx_priority` (`priority`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]]
    
    MySQL.Async.execute(CreateTableQuery, {}, function(result)
        print('^2[qb-todo]^7 Database table initialized')
    end)
end

-- Get player todos
QBCore.Functions.CreateCallback('qb-todo:server:GetTodos', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then
        cb({})
        return
    end
    
    local citizenid = Player.PlayerData.citizenid
    
    MySQL.Async.fetchAll('SELECT * FROM `' .. Config.DatabaseTable .. '` WHERE citizenid = ? ORDER BY priority DESC, due_date ASC, created_at DESC LIMIT ?', 
    {citizenid, Config.MaxTodos}, function(result)
        cb(result or {})
    end)
end)

-- Add new todo
QBCore.Functions.CreateCallback('qb-todo:server:AddTodo', function(source, cb, text, priority, category, dueDate)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then
        cb(false, nil)
        return
    end
    
    local citizenid = Player.PlayerData.citizenid
    text = string.gsub(text or '', "'", "''")
    priority = priority or Config.DefaultPriority
    category = category or 'Other'
    
    if string.len(text) > Config.MaxTaskLength then
        cb(false, nil)
        return
    end
    
    MySQL.Async.fetchScalar('SELECT COUNT(*) FROM `' .. Config.DatabaseTable .. '` WHERE citizenid = ? AND completed = 0', 
    {citizenid}, function(count)
        if count >= Config.MaxTodos then
            cb(false, nil)
            return
        end
        
        local todoId = tostring(math.random(100000, 999999)) .. '-' .. os.time()
        local dueDateValue = (dueDate and dueDate ~= '') and dueDate or nil
        
        MySQL.Async.insert('INSERT INTO `' .. Config.DatabaseTable .. '` (citizenid, todo_id, text, priority, category, due_date, completed) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {citizenid, todoId, text, priority, category, dueDateValue, 0}, function(id)
            if id then
                cb(true, {
                    id = todoId,
                    todo_id = todoId,
                    text = text,
                    priority = priority,
                    category = category,
                    due_date = dueDateValue,
                    completed = false,
                    created_at = os.date('%Y-%m-%d %H:%M:%S')
                })
            else
                cb(false, nil)
            end
        end)
    end)
end)

-- Toggle todo completion
QBCore.Functions.CreateCallback('qb-todo:server:ToggleTodo', function(source, cb, todoId)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then
        cb(false)
        return
    end
    
    local citizenid = Player.PlayerData.citizenid
    local completedAt = os.date('%Y-%m-%d %H:%M:%S')
    
    MySQL.Async.fetchScalar('SELECT completed FROM `' .. Config.DatabaseTable .. '` WHERE todo_id = ? AND citizenid = ?',
    {todoId, citizenid}, function(completed)
        if completed == nil then
            cb(false)
            return
        end
        
        local newState = completed == 0 and 1 or 0
        local completedAtValue = newState == 1 and completedAt or nil
        
        MySQL.Async.execute('UPDATE `' .. Config.DatabaseTable .. '` SET completed = ?, completed_at = ? WHERE todo_id = ? AND citizenid = ?',
        {newState, completedAtValue, todoId, citizenid}, function(rowsChanged)
            cb(rowsChanged > 0)
        end)
    end)
end)

-- Update todo (priority, category, due date)
QBCore.Functions.CreateCallback('qb-todo:server:UpdateTodo', function(source, cb, todoId, priority, category, dueDate)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then
        cb(false)
        return
    end
    
    local citizenid = Player.PlayerData.citizenid
    
    MySQL.Async.execute('UPDATE `' .. Config.DatabaseTable .. '` SET priority = ?, category = ?, due_date = ? WHERE todo_id = ? AND citizenid = ?',
    {priority, category, dueDate, todoId, citizenid}, function(rowsChanged)
        cb(rowsChanged > 0)
    end)
end)

-- Delete todo
QBCore.Functions.CreateCallback('qb-todo:server:DeleteTodo', function(source, cb, todoId)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then
        cb(false)
        return
    end
    
    local citizenid = Player.PlayerData.citizenid
    
    MySQL.Async.execute('DELETE FROM `' .. Config.DatabaseTable .. '` WHERE todo_id = ? AND citizenid = ?',
    {todoId, citizenid}, function(rowsChanged)
        cb(rowsChanged > 0)
    end)
end)

-- Clear all completed todos
QBCore.Functions.CreateCallback('qb-todo:server:ClearCompleted', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then
        cb(false, 0)
        return
    end
    
    local citizenid = Player.PlayerData.citizenid
    
    MySQL.Async.execute('DELETE FROM `' .. Config.DatabaseTable .. '` WHERE citizenid = ? AND completed = 1',
    {citizenid}, function(rowsChanged)
        cb(true, rowsChanged)
    end)
end)

-- Clear all todos
QBCore.Functions.CreateCallback('qb-todo:server:ClearAll', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then
        cb(false, 0)
        return
    end
    
    local citizenid = Player.PlayerData.citizenid
    
    MySQL.Async.execute('DELETE FROM `' .. Config.DatabaseTable .. '` WHERE citizenid = ?',
    {citizenid}, function(rowsChanged)
        cb(true, rowsChanged)
    end)
end)

InitDatabase()

print('^2[qb-todo]^7 Server loaded successfully')