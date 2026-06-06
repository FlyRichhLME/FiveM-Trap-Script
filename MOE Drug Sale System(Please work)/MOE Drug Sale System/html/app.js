const phone = document.getElementById('phone');
const statusText = document.getElementById('status');
const timeText = document.getElementById('time');
const callBtn = document.getElementById('callBtn');
const bulkBtn = document.getElementById('bulkBtn');
const statusBtn = document.getElementById('statusBtn');
const closeBtn = document.getElementById('closeBtn');

const pingOverlay = document.getElementById('bulk-ping-overlay');
const transactionOverlay = document.getElementById('transaction-overlay');

let phoneOpen = false;
let bulkPingActive = false;
let pingTimer = null;

// Update time every second
function updateTime() {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    timeText.textContent = `${hours}:${minutes}`;
}

updateTime();
setInterval(updateTime, 1000);

// Handle NUI messages from Lua
window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'open') {
        phone.classList.remove('hidden');
        phoneOpen = true;
        statusText.textContent = data.status || 'READY';
        bulkBtn.style.display = data.bulkEnabled ? 'block' : 'none';
    }

    if (data.action === 'close') {
        phone.classList.add('hidden');
        phoneOpen = false;
    }

    if (data.action === 'bulkPing') {
        showBulkPing(data);
    }

    if (data.action === 'updateStatus') {
        statusText.textContent = data.status || 'READY';
    }

    if (data.action === 'clearBulkPing') {
        clearBulkPing();
    }

    if (data.action === 'showTransaction') {
        showTransaction(data);
    }

    if (data.action === 'updateProgress') {
        updateProgressBar(data.progress);
    }

    if (data.action === 'hideTransaction') {
        transactionOverlay.classList.add('hidden');
    }
});

// Phone button handlers
callBtn.addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/callCustomer`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

bulkBtn.addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/bulkDelivery`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

statusBtn.addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/checkStatus`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).then(res => res.text()).then(data => {
        console.log('Status:', data);
    });
});

closeBtn.addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/closePhone`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

// Show bulk delivery ping notification
function showBulkPing(data) {
    bulkPingActive = true;
    pingOverlay.classList.remove('hidden');
    
    document.getElementById('pingItemCount').textContent = data.itemCount || '0';
    document.getElementById('pingPayout').textContent = data.payout || '0';
    document.getElementById('pingLocation').textContent = data.locationName || 'Unknown';
    
    let timeLeft = data.timeout || 30;
    const timerDisplay = pingOverlay.querySelector('.ping-timer');
    timerDisplay.textContent = `${timeLeft}s`;
    
    if (pingTimer) clearInterval(pingTimer);
    
    pingTimer = setInterval(() => {
        timeLeft--;
        timerDisplay.textContent = `${timeLeft}s`;
        
        if (timeLeft <= 0) {
            clearInterval(pingTimer);
            rejectBulkPing();
        }
    }, 1000);
    
    const acceptBtn = pingOverlay.querySelector('#acceptPing');
    const rejectBtn = pingOverlay.querySelector('#rejectPing');
    
    // Remove old event listeners
    acceptBtn.replaceWith(acceptBtn.cloneNode(true));
    rejectBtn.replaceWith(rejectBtn.cloneNode(true));
    
    const newAcceptBtn = pingOverlay.querySelector('#acceptPing');
    const newRejectBtn = pingOverlay.querySelector('#rejectPing');
    
    newAcceptBtn.addEventListener('click', acceptPing);
    newRejectBtn.addEventListener('click', rejectBulkPing);
}

function acceptPing() {
    if (pingTimer) clearInterval(pingTimer);
    fetch(`https://${GetParentResourceName()}/acceptBulkPing`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    clearBulkPing();
}

function rejectBulkPing() {
    if (pingTimer) clearInterval(pingTimer);
    fetch(`https://${GetParentResourceName()}/rejectBulkPing`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    clearBulkPing();
}

function clearBulkPing() {
    bulkPingActive = false;
    pingOverlay.classList.add('hidden');
    if (pingTimer) clearInterval(pingTimer);
}

// Show transaction progress
function showTransaction(data) {
    transactionOverlay.classList.remove('hidden');
    document.getElementById('transactionLabel').textContent = data.label || 'Processing transaction...';
    updateProgressBar(0);
}

function updateProgressBar(progress) {
    const circle = document.querySelector('.progress-fill');
    const circumference = 282.7;
    const offset = circumference - (progress / 100) * circumference;
    circle.style.strokeDashoffset = offset;
    document.getElementById('progressPercent').textContent = Math.round(progress) + '%';
}
