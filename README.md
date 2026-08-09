<h1 align="center">Perihelion</h1>

<p align="center">A rogue-like top down game where you connect towers together to create areas of damage.</p>

<p align="center">
  <img src="https://user-cdn.hackclub-assets.com/019fe67c-842b-7143-b6e1-ef4493d5579f/full_game_readme_image.png" width="100%">
</p>

<p align="center">
  <img src="https://user-cdn.hackclub-assets.com/019fe67f-740c-7dd6-b030-3442e914f9fa/you_died_page_readme.png" width="49%" height="280" style="object-fit: cover;">
  <img src="https://user-cdn.hackclub-assets.com/019fe684-fb17-7521-a6e9-248d50a60d56/abilities_selection_readme.png" width="49%" height="280" style="object-fit: cover;">
</p>

## Local Setup

1. Install [Godot 4.6](https://godotengine.org/download) or later (this project uses the Forward+ / GL Compatibility renderer and Jolt Physics).
2. Clone the repo:
   ```
   git clone <this-repo-url>
   cd polarizz
   ```
3. Open Godot, click **Import**, and select the `project.godot` file in the cloned folder.
4. Once the project is open, press **F5** (or the Run button in the top-right) to launch the game. The main scene starts on the scene manager, which loads Level 1 automatically.

No external dependencies or package installs are required — everything the project needs ships in the repo.

## Controls

| Action | Key |
| --- | --- |
| Move | Arrow Keys |
| Dash | Shift (2s cooldown) |
| Bomb | J (10s cooldown, requires a collected Bomb ability) |
| Connect towers | Walk into a tower to draw a line to it — closing the loop between 3+ towers creates a damage zone |
| Respawn after death | Click **Respawn** on the game over screen |
