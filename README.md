## 📱 Godot Implementation of Mobile Network Demonstrator

This is an implementaion of the project Mobile Network Demonstrator with godot 4.3. This program allows user to visually analyze the streucture and performance of a mobile network.

This demonstrator visualizes **signal propagation and user behavior** in a simulated mobile network environment, with a focus on **navigation strategies**, **path blocking logic**, and **signal interaction** in real time.

### 🎯 Objectives
- Simulate user movement across a grid-based environment with path constraints.
- Visualize real-time signal coverage and propagation.
- Test and demonstrate user navigation strategies under variable network conditions.
- Evaluate how users interact with traversable and blocked path areas, including wall collisions and fallback logic.

---

### 🛠️ Key Features
- **Grid-Based Path System**: The environment is divided into square path blocks with defined traversability.
- **User Localization**: Users are positioned using global coordinates mapped to discrete path blocks.
- **Navigation Algorithm**:
  - Users move based on patch type (corner, edge, center).
  - Behavior adjusts dynamically depending on available exits and obstacles.
  - If a block is not traversable, users search for the nearest accessible path block.
- **Wall Detection**:
  - Users cannot pass through buildings or blocked walls.
  - Automatic rerouting is applied when a direct path is obstructed.
- **Simulation Efficiency**:
  - Region search is performed in concentric layers around the user.
  - Early-exit condition ensures minimal computational cost per frame.

---

### 🧪 What You’ll See in the Demo
- Real-time user movement on the path grid.
- Color-coded path blocks indicating traversable and blocked states.
- Smart redirection around walls and impassable zones.
- Dynamic interaction between user position and system logic (e.g., XMem confidence fallback, reroute behavior).

> 📡 This demonstrator serves as an interactive tool to validate mobile network navigation strategies and user behavior in constrained environments. It lays the groundwork for integrating signal propagation models, agent-based simulations, and real-world robotic control in future work.
