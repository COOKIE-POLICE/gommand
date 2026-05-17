<a id="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://github.com/COOKIE-POLICE/gommand/blob/main/LICENSE)

<br />
<div align="center">
  <a href="https://github.com/COOKIE-POLICE/gommand">
	<img src="addons/gommand/assets/editor_icons/icon.png" alt="Logo" width="128" height="128">
  </a>

  <h3 align="center">Gommand</h3>

  <p align="center">
	Gommand is a command-based framework for Godot 4.
	<br />
	<a href="https://cookie-police.github.io/gommand/"><strong>Explore the docs »</strong></a>
	<br />
	<br />
	<a href="https://youtu.be/YOUR-VIDEO-ID">View Demo</a>
	·
	<a href="https://github.com/COOKIE-POLICE/gommand/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
	·
	<a href="https://github.com/COOKIE-POLICE/gommand/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<details>
  <summary>Table of Contents</summary>
  <ol>
	<li>
	  <a href="#about-the-project">About The Project</a>
	  <ul>
		<li><a href="#built-with">Built With</a></li>
	  </ul>
	</li>
	<li><a href="#roadmap">Roadmap</a></li>
	<li><a href="#contributing">Contributing</a></li>
	<li><a href="#license">License</a></li>
	<li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## About The Project

**Gommand** is a command framework for Godot 4 that keeps your code clean.

Instead of managing state machines or tangled control flow, you write small focused commands and compose them into sequences, parallel groups, or conditional flows. The scheduler handles execution order and prevents conflicts automatically.

**What you get:**
- Readable logic: commands have clear names and a single purpose, so the code says exactly what it does
- Declarative style: all your logic lives in one place, no hunting across files to understand what happens
- Composable flows: chain sequences, run things in parallel, add conditions and repeats
- Conflict prevention: subsystem requirements stop commands from clashing
- Input wiring: bind player actions to commands with `ActionTrigger`, no boilerplate

## Gommand At a Glance

### Without Gommand

```gdscript
extends Node3D

var is_dashing := false
var dash_time := 0.0
var attack_pending := false

func _ready() -> void:
    print("Press ui_accept to dash, then attack.")

func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("ui_accept") and not is_dashing:
        is_dashing = true
        dash_time = 0.2
        start_dash()

    if is_dashing:
        dash_time -= delta
        if dash_time <= 0.0:
            is_dashing = false
            stop_dash()
            attack_pending = true

    if attack_pending:
        attack_pending = false
        attack_target()


func start_dash() -> void:
    print("Dash start")


func stop_dash() -> void:
    print("Dash end")


func attack_target() -> void:
    print("Attack")
```

### With Gommand

```gdscript
extends Node3D

var trigger: ActionTrigger


func _ready() -> void:
    print("Press ui_accept to run dash + attack sequence.")

    var dash_and_attack := SequentialCommandGroup.new([
        PrintCommand.new("Dash start"),
        WaitCommand.new(0.2),
        PrintCommand.new("Dash end"),
        PrintCommand.new("Attack"),
    ])

    trigger = (
        ActionTrigger
        .builder("ui_accept")
        .add_on_action_pressed(dash_and_attack)
        .build()
    )
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

* [![Godot][Godot-badge]][Godot-url]
* [![GDScript][GDScript-badge]][GDScript-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Roadmap

- [x] Core framework
- [ ] Command Visualizer
- [ ] Documentation

See the [open issues](https://github.com/COOKIE-POLICE/gommand/issues) for a full list of proposed features and known issues.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Top contributors:

<a href="https://github.com/COOKIE-POLICE/gommand/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=COOKIE-POLICE/gommand" alt="contrib.rocks image" />
</a>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License

Distributed under the MIT License. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Acknowledgments

* [Choose an Open Source License](https://choosealicense.com)
* [Best README Template](https://github.com/othneildrew/Best-README-Template)
* [Img Shields](https://shields.io)
* [GitHub Pages](https://pages.github.com)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
[contributors-shield]: https://img.shields.io/github/contributors/COOKIE-POLICE/gommand.svg?style=for-the-badge
[contributors-url]: https://github.com/COOKIE-POLICE/gommand/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/COOKIE-POLICE/gommand.svg?style=for-the-badge
[forks-url]: https://github.com/COOKIE-POLICE/gommand/network/members
[stars-shield]: https://img.shields.io/github/stars/COOKIE-POLICE/gommand.svg?style=for-the-badge
[stars-url]: https://github.com/COOKIE-POLICE/gommand/stargazers
[issues-shield]: https://img.shields.io/github/issues/COOKIE-POLICE/gommand.svg?style=for-the-badge
[issues-url]: https://github.com/COOKIE-POLICE/gommand/issues
[Godot-badge]: https://img.shields.io/badge/Godot-4.x-478CBF?style=for-the-badge&logo=godotengine&logoColor=white
[Godot-url]: https://godotengine.org/
[GDScript-badge]: https://img.shields.io/badge/GDScript-355570?style=for-the-badge&logo=godotengine&logoColor=white
[GDScript-url]: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/
