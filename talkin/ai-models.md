# Local AI models task

## Status

Not started. The user asked to switch to plan mode before any work on this
begins. Do not install anything or pick models until plan mode is on.

## What the user asked for, verbatim

> мне нужно подобрать локальные ии модели для этих целей
>
> - для работы с obsidian, zettelkasten методологией, obsidian bases, obsidian local graph, для работы с markdown/latex , для работы с документами в общем, пониманием того например куда новую заметку можно добавить, особенно когда в obsidian vault очень много файлов , чтобы это было быстро под мою текущую систему
> - программирование MOE модель со слоями, чтобы видеокарте легче было, в основном веб программирование, но иногда может быть что-то системное на C языке
> - программирование лайт модель для autocomplete
> - для настройки системы nixos и всяких конфигов, по типу neovim, может кстати пересекаться в теории с моделью для программирования
> - для работы с файлами и их перекладывание сортировки
> - креативная ИИ модель для разгона идей сюжетов и тд, чтобы она могла принять роль человека для совместного брейншторма или принять кроль какого-то персонажа и отыгрывать от него, возможно для генерации картинок или дизайн наброска
>
> можешь предоставить прям hugging face ссылки или lm studio с вилки на скачивание их
>
> также возможно мне нужен какой то ии workflow я слышал про [herdr](https://github.com/herdrdev/herdr)(https://herdr.dev/) - это как tmux только для ии сессий с агентами, может мне нужно как-то под настроить [lm studio](https://github.com/lmstudio-ai/lms), еще я слышал про [Odysseus](https://github.com/odysseus-dev/odysseus) для работы с локальными иишками от PewDiePie , как думаешь, мб мне что-то подойдёт для моих целей, может можно ещё попробовать [pi](https://github.com/earendil-works/pi), может быть какой-то [n8n](https://github.com/n8n-io/n8n) для автоматизации чего-то и вообще в идеале конечно чтобы все эти им агенты в изолированной среде запускались, чтобы уменьшить шансы, что они сломают чтото
>
> важно все что я перечислил выше у меня вроде даже не установлено в nixos , у меня есть lm studio, но вроде lms cli для него нет, поэтому если что-то будем устанавливать, то это тоже за тобой
>
> если модели могут выходить в интернет как-то, например для моделей, которые конфигами занимается это может быть crucial,  думаю сначала нужно будет выбрать и настроить модель для работы над конфигами, потому конфиг это точка входа для всего остального
>
> нужны свежие модели на 1 октября 2026 года, мб кстати мне стоит установить какие-то модели вручную или из можно точно прописать через home manager
>
> в общем желательно чтобы хотя бы какие-то  инструменты стыковались друг с другом и были консистеньными для моей текущей nixos системы
>
> так как у меня не прям свежее железо на 2026 год, у меня 1050ti 4gb video ram и 32 gb ram в одноканаде к сожалению и Ryzen 1400 вроде, ну мб ты найдешь способ перепроверить мое железо, в общем модели должны быть оптимальными под мою систему  где-то мб можно поднастроить ради скорости MOE слои например или размер контекста основываясь на моей видео и рам памяти
>
> какие мои дальнейшие шаги, что думаешь вообще стоит начать делать и как настроить или workflow основываясь на том что я тебе предоставил, всегда можешь доп вопросы задавать
>
> в общем идеально было бы подобрать модели под мои задачи, установить настроить необходимые инструменты(из всего перечисленного lm studio приоритет, потом можно уже другими приложениями заняться, Odysseus прикольный вроде, но. я не раду им не пользовался и тл) и настроить их + workflow, плюс ты в теории можешь дать советы, ведь ты сама ИИ и понимаешь что тебе нужно больше всего
>
> мб мне понадобятся какие-то skills, мб ты тоже из подберёшь и желательно чтобы был какой-то tool который позволяет из скачивать удобно, я что-то слышал про этот инструмент [skills](https://github.com/mattpocock/skills) мб он закроет мои задачи

## Requirements pulled out of that text

Hardware budget, all of it tight:

- GTX 1050 Ti, 4 GB VRAM. This is the hard constraint. Anything wider than
  about a 4 bit quantised 7 to 9 billion parameter model will not fit fully,
  so MoE with CPU offload or partial GPU layers is the interesting angle
- 32 GB RAM, single channel. Worth verifying, and worth telling the user that
  dual channel would roughly double memory bandwidth for CPU inference
- Ryzen 1400, no AVX-512 worth counting on, 4 cores 8 threads. Only a few
  simultaneous agents

Model roles wanted:

1. Obsidian and documents: zettelkasten, Bases, local graph, markdown, latex,
   and specifically placing a new note correctly in a large vault. So this
   needs retrieval over the vault, not just generation
2. Programming, MoE, offload layers to fit the GPU. Mostly web, sometimes
   systems C
3. Programming, small, for autocomplete. This one has to be fast and is
   probably the most valuable per token
4. NixOS and config editing, neovim. The user notes this may overlap with 2
5. Files and file organisation, sorting
6. Creative: brainstorming plots, roleplay a character or a person for joint
   thinking, possibly image or sketch generation

Constraints and preferences:

- Fresh models, as of 1 October 2026. Nothing from memory, this has to be
  researched, model versions move fast
- Direct Hugging Face links or LM Studio download links
- Nothing from the list is installed on NixOS yet. `lms` CLI is missing even
  though LM Studio exists
- Tooling priority: LM Studio first, then the others
- Wants the tools to interoperate and to be consistent with the existing NixOS
  setup
- Ask whether to install models manually or pin them through home-manager
- Internet access for models matters, and the user considers it crucial for the
  config-editing model specifically
- The user thinks the config model should come first, because config is the
  entry point for everything else
- Agents should run isolated, to reduce the chance of them breaking something
- Workflow tooling to look at: herdr, lm studio and its `lms` CLI, Odysseus,
  pi, n8n
- Skills may be wanted, the user mentioned mattpocock/skills as a possible
  download tool
- Ask follow-up questions freely
- Wants advice from the assistant's own point of view about what it needs most

## Open questions to settle before implementing

- Verify the actual hardware first. `lspci`, `lscpu`, `free -h`, RAM channels
  from `lmcpu` or `/proc/meminfo`, and what CUDA toolkit or ROCm is present
- LM Studio is a GUI app. Does it fit the niri setup, or should the work go
  through `lms` headless and an OpenAI-compatible local endpoint, with a UI
  only when wanted
- Isolation story. Podman is already there. Are agents containerised, or
  sandboxed some other way, and what is the realistic threat
- Internet access per model. Local inference has no network by itself, so this
  is about whether tools fetch, and what gets exposed
- Retrieval for the vault. Obsidian Bases and graph features may need
  something beyond a model, like an embedding model plus a vector index, and
  that has to be picked too
- Image generation is a separate hardware question. 4 GB VRAM constrains it
  hard
- Budget for disk. Each model is tens of GB and `/` has 386 GB free
