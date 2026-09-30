# EDDMail — Data Structures in Practice | EDDMail — Estructuras de datos aplicadas

**Repository name suggestion:** `eddmail-data-structures`  
**Nombre en español:** `EDDMail — Correo y comunidades con estructuras de datos`  
**Description:** EDDMail desktop email simulation built around linked lists, stacks, queues, sparse matrices, balanced trees and structure visualizations.

## English

### Overview

This repository brings together three phases of **EDDMail**, a desktop email and community simulator developed to demonstrate how classic data structures can support application features. The project source is organized by phase; each phase has its own Lazarus project, documentation and reports. A set of standalone exercises also includes a binary search tree loaded from JSON and an undirected graph visualization.

### Structures used in EDDMail

| Data structure | Application in the project |
|---|---|
| Singly linked list | Stores users and connects user records to their application data. |
| Doubly linked list | Stores received messages in an inbox and supports traversal in both directions. |
| Circular linked list | Stores a user’s contacts. |
| Stack | Models the deleted-message trash using `push` and `pop` operations. |
| Queue | Holds scheduled messages using enqueue and dequeue operations. |
| Sparse matrix | Represents relationships between users without allocating a dense matrix. |
| List of lists | Groups users under communities. |
| AVL tree | Indexes email drafts; includes insertion, search, deletion and balancing rotations. |
| B-tree of order 5 | Organizes favorite messages by ID for searching and ordered traversal. |
| Binary search tree (BST) | Organizes communities and related users/messages for tree operations and reports. |
| Hash-linked list (“blockchain” exercise) | Appends message metadata with a previous-hash link and provides a chain validation routine. The implementation uses MD5 for this data-structures exercise; it is not a production security mechanism. |

### How the phases build on one another

- **Project 1:** core mail features backed by linked lists, a stack, a queue, a sparse matrix and a list of lists.
- **Project 2:** adds AVL and B-tree indexes for drafts and favorites, plus a BST-oriented community view.
- **Project 3:** extends the mail model with a hash-linked record chain and its validation/visualization code.

The repository also contains separate exercises under `T2/` and `T4/`: a BST example that loads data from JSON and an undirected graph rendered with Graphviz.

### Visualization

Several implementations export their structure to Graphviz DOT and render PNG reports. This makes links, tree branches, matrix relationships, scheduled messages, trash contents and community organization easier to inspect.

### Technology and tools

- Object Pascal with Free Pascal / Lazarus
- Pointer-based nodes and records for the data structures
- Lazarus forms (`.lfm`) for the desktop interface
- Graphviz (`dot`) for DOT-to-PNG reports
- JSON input in the standalone BST exercise

The data structures are the focus of this portfolio entry; Pascal is the implementation language.

### Repository layout

```text
Proyecto 1 EDD/
  Unidades/       Core lists, stack, queue, sparse matrix and communities
  Formularios/    Lazarus desktop application and reports
  *.pdf           Technical, user and integration manuals
Proyecto 2 EDD/
  Unidades/       Core structures plus AVL, B-tree and BST modules
  Formularios/    Drafts, favorites, communities and reports
  *.pdf           Phase 2 manuals
Proyecto 3 EDD/
  Unidades/       Mail structures plus hash-linked message records
  Formularios/    Updated application and reports
  *.pdf           Phase 2 manuals
T2/               BST example using JSON input
T4/               Undirected graph and Graphviz output
```

### Build and run

Install Lazarus with Free Pascal and Graphviz. Open the `.lpi` project file for the phase you want to explore in Lazarus. The project files are located at:

```text
Proyecto 1 EDD/Formularios/project1.lpi
Proyecto 2 EDD/Formularios/project1.lpi
Proyecto 3 EDD/Formularios/project1.lpi
```

Graphviz is required for regenerating visual reports. The repository includes generated binaries and reports, but opening the Lazarus project is the recommended way to build from source.

### Documentation

- [Project 1 technical manual](https://github.com/Deltai-cod12/-EDD-1S2025_202404856/blob/main/Proyecto%201%20EDD/Manual%20Tecnico_202404856.pdf)
- [Project 1 user manual](https://github.com/Deltai-cod12/-EDD-1S2025_202404856/blob/main/Proyecto%201%20EDD/Manual%20de%20Usuario_202404856.pdf)
- [Project 1 integration manual](https://github.com/Deltai-cod12/-EDD-1S2025_202404856/blob/main/Proyecto%201%20EDD/Manual%20de%20Integracion.pdf)
- [Project 2 technical manual](https://github.com/Deltai-cod12/-EDD-1S2025_202404856/blob/main/Proyecto%202%20EDD/Manual%20Tecnico%20Fase%202_202404856.pdf)
- [Project 3 technical manual](https://github.com/Deltai-cod12/-EDD-1S2025_202404856/blob/main/Proyecto%203%20EDD/Manual%20Tecnico%20Fase%202_202404856.pdf)

### Academic context

Coursework developed for the Data Structures course at Universidad de San Carlos de Guatemala.

## Español

### Descripción

Este repositorio reúne tres fases de **EDDMail**, un simulador de correo y comunidades de escritorio creado para mostrar cómo las estructuras de datos clásicas pueden resolver necesidades de una aplicación. El código está organizado por fase; cada una tiene su propio proyecto de Lazarus, documentación y reportes. También se incluyen ejercicios independientes de un árbol binario de búsqueda cargado desde JSON y un grafo no dirigido visualizado con Graphviz.

### Estructuras utilizadas en EDDMail

| Estructura de datos | Uso dentro del proyecto |
|---|---|
| Lista simplemente enlazada | Almacena usuarios y conecta cada usuario con sus datos de aplicación. |
| Lista doblemente enlazada | Almacena los mensajes recibidos en la bandeja y permite recorrerlos en ambos sentidos. |
| Lista circular | Almacena los contactos de cada usuario. |
| Pila | Modela la papelera de mensajes eliminados mediante operaciones `push` y `pop`. |
| Cola | Mantiene los mensajes programados mediante operaciones de inserción y extracción. |
| Matriz dispersa | Representa relaciones entre usuarios sin reservar una matriz densa completa. |
| Lista de listas | Agrupa usuarios dentro de comunidades. |
| Árbol AVL | Indexa borradores; incluye inserción, búsqueda, eliminación y rotaciones de balanceo. |
| Árbol B de orden 5 | Organiza mensajes favoritos por ID para búsqueda y recorrido ordenado. |
| Árbol binario de búsqueda (BST) | Organiza comunidades y usuarios/mensajes asociados para operaciones y reportes del árbol. |
| Lista enlazada con hashes (“blockchain” educativa) | Agrega registros de metadatos de mensajes enlazados con el hash anterior y permite validar la cadena. La implementación usa MD5 como ejercicio de estructuras de datos; no es un mecanismo de seguridad para producción. |

### Evolución entre fases

- **Proyecto 1:** funciones base de correo con listas enlazadas, pila, cola, matriz dispersa y lista de listas.
- **Proyecto 2:** agrega índices AVL y B-tree para borradores y favoritos, además de una vista de comunidades basada en BST.
- **Proyecto 3:** amplía el modelo con una cadena de registros de mensajes enlazados por hash y código para validarla y visualizarla.

También hay ejercicios independientes en `T2/` y `T4/`: un ejemplo de BST que carga datos desde JSON y un grafo no dirigido renderizado con Graphviz.

### Visualización

Varias implementaciones exportan sus estructuras a Graphviz DOT y generan reportes PNG. Así se pueden inspeccionar enlaces, ramas de árboles, relaciones de la matriz, mensajes programados, papelera y comunidades.

### Tecnologías y herramientas

- Object Pascal con Free Pascal / Lazarus
- Nodos basados en punteros y registros para implementar las estructuras
- Formularios Lazarus (`.lfm`) para la interfaz de escritorio
- Graphviz (`dot`) para generar reportes DOT a PNG
- Entrada JSON en el ejercicio independiente de BST

El enfoque de esta presentación son las estructuras de datos; Pascal es el lenguaje utilizado para implementarlas.

### Organización del repositorio

```text
Proyecto 1 EDD/
  Unidades/       Listas, pila, cola, matriz dispersa y comunidades
  Formularios/    Aplicación de escritorio Lazarus y reportes
  *.pdf           Manuales técnico, de usuario e integración
Proyecto 2 EDD/
  Unidades/       Estructuras base más módulos AVL, B-tree y BST
  Formularios/    Borradores, favoritos, comunidades y reportes
  *.pdf           Manuales de la fase 2
Proyecto 3 EDD/
  Unidades/       Estructuras de correo y registros enlazados por hash
  Formularios/    Aplicación actualizada y reportes
  *.pdf           Manuales de la fase 2
T2/               Ejemplo de BST con entrada JSON
T4/               Grafo no dirigido y salida de Graphviz
```

### Compilar y ejecutar

Instala Lazarus con Free Pascal y Graphviz. Abre en Lazarus el archivo `.lpi` de la fase que quieras revisar. Las rutas de los proyectos son:

```text
Proyecto 1 EDD/Formularios/project1.lpi
Proyecto 2 EDD/Formularios/project1.lpi
Proyecto 3 EDD/Formularios/project1.lpi
```

Graphviz es necesario para regenerar los reportes visuales. El repositorio incluye binarios y reportes ya generados; se recomienda abrir el proyecto de Lazarus para compilar desde el código fuente.

### Documentación

- [Manual técnico del proyecto 1](https://github.com/Deltai-cod12/-EDD-1S2025_202404856/blob/main/Proyecto%201%20EDD/Manual%20Tecnico_202404856.pdf)
- [Manual de usuario del proyecto 1](https://github.com/Deltai-cod12/-EDD-1S2025_202404856/blob/main/Proyecto%201%20EDD/Manual%20de%20Usuario_202404856.pdf)
- [Manual de integración del proyecto 1](https://github.com/Deltai-cod12/-EDD-1S2025_202404856/blob/main/Proyecto%201%20EDD/Manual%20de%20Integracion.pdf)
- [Manual técnico del proyecto 2](https://github.com/Deltai-cod12/-EDD-1S2025_202404856/blob/main/Proyecto%202%20EDD/Manual%20Tecnico%20Fase%202_202404856.pdf)
- [Manual técnico del proyecto 3](https://github.com/Deltai-cod12/-EDD-1S2025_202404856/blob/main/Proyecto%203%20EDD/Manual%20Tecnico%20Fase%202_202404856.pdf)

### Contexto académico

Trabajo académico del curso de Estructuras de Datos de la Universidad de San Carlos de Guatemala.

---

**Topics:** `data-structures`, `algorithms`, `linked-list`, `stack`, `queue`, `sparse-matrix`, `avl-tree`, `b-tree`, `binary-search-tree`, `graphviz`, `lazarus`, `free-pascal`
