# flutter-algorithm-visualizer
## Still in an initial state.

Flutter Algorithm and Data Structure Visualizer is an interactive learning tool designed to help students, developers, and enthusiasts understand how algorithms and data structures work under the hood. Built with Flutter, it provides a smooth, cross-platform experience on both mobile and desktop.

The app features intuitive step-by-step animations that bring abstract concepts like sorting, searching, graphs, and pathfinding to life. Users can watch how algorithms process it in real time and adjust the speed of execution for deeper exploration.

Key highlights include:

- 📊 Sorting Algorithms – Visualize Bubble Sort, Merge Sort, Quick Sort, and more.

- 🌐 Graph Algorithms – Understand BFS and shortest path algorithms like A*.

- 🎨 Clean UI & Smooth Animations – Built with Flutter’s powerful rendering system for responsive and engaging visuals.

Whether you are preparing for coding interviews, studying computer science fundamentals, or just curious about algorithms, this app makes learning interactive, visual, and fun.

## SnapShots
<img width="32%" height="50%" alt="1" src="https://github.com/user-attachments/assets/b62efbb1-cc42-4a9b-993d-f028043f00c1" />
<img width="32%" height="50%" alt="2" src="https://github.com/user-attachments/assets/1ab173f5-0550-4330-81cf-90fe4184cf2f" />
<!-- <img width="400" height="851" alt="2" src="https://github.com/user-attachments/assets/34862806-b4fa-4b6f-b6d8-b478db7ba2d5" /> -->

<!-- <img width="400" height="851" alt="3" src="https://github.com/user-attachments/assets/58e238f7-1621-4d9b-aa63-e2eaa0e2e26d" /> -->
<img width="32%" height="50%" alt="3" src="https://github.com/user-attachments/assets/9d4bbce8-9593-4896-91dc-c3f7767d0989" />
<img width="32%" height="50%" alt="4" src="https://github.com/user-attachments/assets/f54067b1-1f2f-4d61-8667-8a643ccaf9cc" />
<!-- <img width="400" height="851" alt="4" src="https://github.com/user-attachments/assets/f16a2d3e-5538-406d-9a97-67be8baa6ae1" /> -->

<!-- <img width="400" height="851" alt="5" src="https://github.com/user-attachments/assets/24a40ff2-38b1-48b4-a213-86963f109ad7" /> -->
<img width="32%" height="50%" alt="5" src="https://github.com/user-attachments/assets/735eccba-51c8-4543-91b9-24224c255bf4" />
<img width="32%" height="50%" alt="6" src="https://github.com/user-attachments/assets/f623434c-dbfe-4845-8c4e-6d67a867875c" />

<!-- <img width="400" height="851" alt="7" src="https://github.com/user-attachments/assets/c0a02799-7a21-4fab-b00b-89f8f2e86d6b" /> -->
<img width="32%" height="50%" alt="7" src="https://github.com/user-attachments/assets/ed9649a8-6d7b-4508-922d-e5ef22d7a637" />
<img width="32%" height="50%" alt="8" src="https://github.com/user-attachments/assets/0d0051e9-fec0-4c79-9161-ed6d4d64e11d" />



### Initially, we will cover:

| Category       | Algorithm                  | Status |
|----------------|----------------------------|--------|
| **Graphs**     | BFS                        | ✅     |
|                | DFS                        | ✅     |
|                | Dijkstra                   | ❌     |
|                | A* Search                  | ✅     |
|                | ...More                    |        |
|----------------|----------------------------|--------|
| **Mazes**      | Backtracking               | ❌     |
|                | Eller's maze               | ❌     |
|                | Randomized Kruskal's maze  | ❌     |
|                | Aldous-Broder              | ❌     |
|                | Recursive Division         | ❌     |
|                | Binary Tree                | ❌     |
|----------------|----------------------------|--------|
| **Sorting**    | Bubble Sort                | ✅     |
|                | Selection Sort             | ✅     |
|                | Insertion Sort             | ✅     |
|                | Merge Sort                 | ✅     |
|                | Quick Sort                 | ✅     |
|                | Radix Sort                 | ✅     |
|                | Heap Sort                  | ✅     |
|                | Bucket Sort                | ✅     |
|                | Counting Sort              | ✅     |
|                | Shell Sort                 | ✅     |
|----------------|----------------------------|--------|
| **Trees**      | Binary Tree                | ❌     |
|                | Binary Search Tree         | ❌     |
|                | Ternary Tree               | ❌     |
|                | AVL Tree                   | ❌     |
|                | Red-Black Tree             | ❌     |
|                | Segment Tree               | ❌     |
|                | N-ary Tree                 | ❌     |
|                | B-Tree                     | ❌     |
|----------------|----------------------------|--------|
| **Linked List**| Single                     | ❌     |
|                | Double                     | ❌     |
|                | Circular                   | ❌     |
|                | Circular doubly            | ❌     |

**And more will be added later:**
- Dynamic Programming
- Machine Learning Algorithms
- Networking Algorithms
- String Algorithms
- And more...

- We will also write an explanation code for every algorithm in several languages.
- Compare different algorithms with the interaction way

---

## Flavors (dev / staging / production)

The app ships in three flavors, each with its own name, application id, launcher
icon and Firebase project.

| Flavor       | Entry point            | App name        | Android applicationId          | iOS bundle id                  | Icon           |
| ------------ | ---------------------- | --------------- | ------------------------------ | ------------------------------ | -------------- |
| `dev`        | `lib/main_dev.dart`     | AlgoDive Dev    | `com.elhawary.algodive.dev`     | `com.elhawary.algodive.dev`     | red **DEV** ribbon |
| `staging`    | `lib/main_staging.dart` | AlgoDive Stag   | `com.elhawary.algodive.staging` | `com.elhawary.algodive.staging` | red **STAGING** ribbon |
| `production` | `lib/main_prod.dart`    | AlgoDive        | `com.elhawary.algodive`         | `com.elhawary.algodive`         | clean          |

`lib/main.dart` is **not** launchable — it throws. Always launch a flavored
entry point.

### Run

```bash
# dev
flutter run --flavor dev        -t lib/main_dev.dart     --dart-define-from-file=dart_define/dev.json
# staging
flutter run --flavor staging    -t lib/main_staging.dart --dart-define-from-file=dart_define/staging.json
# production
flutter run --flavor production  -t lib/main_prod.dart    --dart-define-from-file=dart_define/prod.json
```

Release/appbundle builds use the same three flags, e.g.
`flutter build appbundle --release --flavor production -t lib/main_prod.dart --dart-define-from-file=dart_define/prod.json`.

VS Code: pick **dev / staging / production** in the Run and Debug panel.
Android Studio / IntelliJ: pick the **dev / staging / production** run configuration.

### Docs

| Doc | What it covers |
| --- | --- |
| [docs/flavors/README.md](docs/flavors/README.md) | Full reference: folder layout, env config, how to add a 4th flavor, branch → environment map |
| [docs/flavors/FIREBASE_CHECKLIST.md](docs/flavors/FIREBASE_CHECKLIST.md) | The exact 6 Firebase files to download and where each one goes |
| [docs/flavors/IOS_XCODE_SETUP.md](docs/flavors/IOS_XCODE_SETUP.md) | One-time Xcode step: create the per-flavor build configs, schemes and the Firebase Run Script phase |
| [docs/flavors/PLAYBOOK.md](docs/flavors/PLAYBOOK.md) | Day-to-day situations: new dependency, new Firebase service, hotfix, key rotation, onboarding, troubleshooting |

