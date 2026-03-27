const app = document.getElementById('app');
const closeBtn = document.getElementById('closeBtn');
const createForm = document.getElementById('createForm');
const dynamicList = document.getElementById('dynamicList');
const staticList = document.getElementById('staticList');
app.classList.add('hidden');
app.style.display = 'none';
document.body.classList.remove('ui-visible');

const postNui = async (eventName, payload = {}) => {
  await fetch(`https://${GetParentResourceName()}/${eventName}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(payload)
  });
};

const formatCoords = (coords) => {
  const x = Number(coords?.x ?? 0).toFixed(2);
  const y = Number(coords?.y ?? 0).toFixed(2);
  const z = Number(coords?.z ?? 0).toFixed(2);
  return `${x}, ${y}, ${z}`;
};

const createBlipItem = (blip, dynamic) => {
  const li = document.createElement('li');
  li.className = 'blip-item';
  li.innerHTML = `
    <strong>${blip.name}</strong>
    <div class="meta">ID: ${blip.id} | Sprite: ${blip.sprite} | Color: ${blip.color}</div>
    <div class="meta">Coords: ${formatCoords(blip.coords)}</div>
  `;

  if (dynamic) {
    const actions = document.createElement('div');
    actions.className = 'actions';

    const routeBtn = document.createElement('button');
    routeBtn.className = 'route';
    routeBtn.textContent = 'Route';
    routeBtn.onclick = () => postNui('setRoute', { id: blip.id });

    const removeBtn = document.createElement('button');
    removeBtn.className = 'remove';
    removeBtn.textContent = 'Remove';
    removeBtn.onclick = () => postNui('removeBlip', { id: blip.id });

    actions.append(routeBtn, removeBtn);
    li.appendChild(actions);
  }

  return li;
};

const renderList = (el, list, dynamic) => {
  el.innerHTML = '';
  if (!Array.isArray(list) || list.length === 0) {
    el.innerHTML = '<li class="empty">No blips found.</li>';
    return;
  }

  list.forEach((blip) => el.appendChild(createBlipItem(blip, dynamic)));
};

window.addEventListener('message', (event) => {
  const data = event.data || {};

  if (data.action === 'toggle') {
    app.style.display = data.open ? 'grid' : 'none';
    app.classList.toggle('hidden', !data.open);
    document.body.classList.toggle('ui-visible', data.open === true);
    return;
  }

  if (data.action === 'state') {
    renderList(dynamicList, data.dynamicBlips || [], true);
    renderList(staticList, data.staticBlips || [], false);
  }
});

closeBtn.addEventListener('click', () => postNui('close'));

createForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  const form = new FormData(createForm);

  await postNui('createBlip', {
    id: form.get('id'),
    name: form.get('name'),
    x: Number(form.get('x')),
    y: Number(form.get('y')),
    z: Number(form.get('z')),
    sprite: Number(form.get('sprite')),
    color: Number(form.get('color')),
    scale: Number(form.get('scale')),
    shortRange: form.get('shortRange') === 'on'
  });

  createForm.reset();
});

window.addEventListener('keydown', (event) => {
  if (event.key === 'Escape') {
    postNui('close');
  }
});
