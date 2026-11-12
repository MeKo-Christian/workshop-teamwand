// Renders window.TEAM as cards. DOM nodes are built with textContent, never
// innerHTML, so an entry cannot inject markup into the page.
(function () {
  "use strict";

  function createCard(entry) {
    const card = document.createElement("li");
    card.className = "card";

    const emoji = document.createElement("div");
    emoji.className = "emoji";
    emoji.textContent = entry.emoji;

    const name = document.createElement("p");
    name.className = "name";
    name.textContent = entry.name;

    const login = document.createElement("a");
    login.className = "login";
    login.href = `https://github.com/${encodeURIComponent(entry.login)}`;
    login.textContent = `@${entry.login}`;

    const motto = document.createElement("p");
    motto.className = "motto";
    motto.textContent = entry.motto;

    card.append(emoji, name, login, motto);
    return card;
  }

  function render() {
    const wall = document.getElementById("wall");
    const visible = window.TEAM;
    wall.replaceChildren(...visible.map(createCard));

    document.getElementById("version").textContent = `Version ${window.APP_VERSION}`;
  }

  render();
})();
