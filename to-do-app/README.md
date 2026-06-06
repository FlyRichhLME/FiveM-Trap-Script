# To-Do List Application

A modern, responsive to-do list web application with local storage functionality. Stay organized and manage your tasks efficiently!

## Features

✨ **Core Functionality**
- ✅ Add new tasks with keyboard support (Enter key)
- ✅ Mark tasks as complete/incomplete
- ✅ Delete individual tasks
- ✅ Clear all completed tasks
- ✅ Clear all tasks

🎯 **Organization**
- Filter tasks by: All, Active, Completed
- Real-time statistics (Total, Completed, Remaining)
- Task timestamps showing when created
- Empty state indicator

💾 **Data Persistence**
- All tasks saved to browser's local storage
- Automatic persistence on every action
- Data survives page refresh and browser restart
- Error handling for storage issues

🎨 **User Interface**
- Beautiful gradient design
- Smooth animations and transitions
- Responsive design (mobile, tablet, desktop)
- Intuitive controls and visual feedback
- Hover effects and active states

## How to Use

1. **Add a Task**: Type in the input field and click "Add Task" or press Enter
2. **Complete a Task**: Click the checkbox next to a task
3. **Delete a Task**: Click the "Delete" button on any task
4. **Filter Tasks**: Use the filter buttons to view All, Active, or Completed tasks
5. **Clear Tasks**: Use action buttons to clear completed tasks or all tasks

## Local Storage

All tasks are automatically saved to your browser's local storage:
- Tasks persist across page refreshes
- Tasks survive browser restart
- Storage location: `localStorage['todos']`
- Max storage: ~5-10MB (depends on browser)

## File Structure

```
to-do-app/
├── index.html      # HTML structure
├── style.css       # Styling and animations
├── script.js       # JavaScript logic and storage
└── README.md       # This file
```

## Browser Compatibility

- ✅ Chrome/Edge (latest)
- ✅ Firefox (latest)
- ✅ Safari (latest)
- ✅ Mobile browsers

## Technical Details

### Data Structure
```javascript
{
    id: timestamp,
    text: "Task description",
    completed: false,
    createdAt: "Date string"
}
```

### Storage Limits
- Stored as JSON string in localStorage
- Typical limit: 5-10MB per domain
- Backup your data regularly

## Tips

- Use descriptive task names for better organization
- Check the statistics to track your progress
- Filter by "Active" to focus on remaining tasks
- Use "Clear Completed" regularly to keep list clean

## Future Enhancements

- [ ] Priority levels (High, Medium, Low)
- [ ] Task categories/tags
- [ ] Due dates and reminders
- [ ] Export/Import functionality
- [ ] Dark mode
- [ ] Search functionality
- [ ] Local database (IndexedDB) for more storage

## License

Free to use and modify for personal projects.

Enjoy staying productive! 🚀
