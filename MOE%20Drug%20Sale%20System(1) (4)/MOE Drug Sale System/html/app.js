let bulkEnabled = false;
let deliveryEnabled = false;

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.action) return;

    if (data.action === 'open') {
        document.getElementById('trap-phone').style.display = 'block';
        document.getElementById('status-label').innerText = `STATUS: ${data.status || 'READY'}`;
        bulkEnabled = !!data.bulkEnabled;
        deliveryEnabled = !!data.deliveryEnabled;

        logMessage(`Trap phone ready. Use ${data.command || '/trap'} or buttons.`);
        updateButtons();
    }

    if (data.action === 'close') {
        document.getElementById('trap-phone').style.display = 'none';
    }

    if (data.action === 'statusUpdate') {
        document.getElementById('status-label').innerText = `STATUS: ${data.status || 'READY'}`;
    }

    if (data.action === 'repUpdate') {
        document.getElementById('rep-label').innerText = `REP: ${data.repLabel || 'Unknown'} (${data.repValue || 0})`;
    }

    if (data.action === 'log') {
        logMessage(data.message || '');
    }
});

function updateButtons() {
    document.getElementById('btn-bulk').style.display = bulkEnabled ? 'inline-block' : 'none';
    document.getElementById('btn-delivery').style.display = deliveryEnabled ? 'inline-block' : 'none';
}

function logMessage(msg) {
    if (!msg) return;
    const log = document.getElementById('log');
    const line = document.createElement('div');
    line.textContent = msg;
    log.appendChild(line);
    log.scrollTop = log.scrollHeight;
}

document.getElementById('btn-close').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/closePhone`, {
        method: 'POST',
        body: JSON.stringify({})
    });
});

document.getElementById('btn-call').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/callCustomer`, {
        method: 'POST',
        body: JSON.stringify({})
    });
});

document.getElementById('btn-bulk').addEventListener('click', () => {
    if (!bulkEnabled) {
        logMessage('Bulk delivery is disabled.');
        return;
    }
    fetch(`https://${GetParentResourceName()}/bulkDelivery`, {
        method: 'POST',
        body: JSON.stringify({})
    });
});

document.getElementById('btn-delivery').addEventListener('click', () => {
    if (!deliveryEnabled) {
        logMessage('Delivery system is disabled.');
        return;
    }
    fetch(`https://${GetParentResourceName()}/startDelivery`, {
        method: 'POST',
        body: JSON.stringify({})
    });
});
