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
	<a href="https://gommand.gitbook.io/gommand/"><strong>Explore the docs »</strong></a>
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

Gommand is a command-based framework for Godot 4 inspired by WPILib's command-based programming system. Gommand allows you to follow a declarative programming style. The emphasis is on what your game or application should do rather than how to do it. This minimizes the step-by-step logic normally required to write out a certain action.

### Why Commands Over States?

- **Actions, not states**: A player doesn’t exist in a “run state” or “walk state”; a player runs, a player walks. Commands reflect behavior directly, matching how we naturally describe actions.

- **No transition hell**: State machines require explicit transitions between every state pair. You need sprint→walk, walk→idle, idle→crouch, crouch→jump transitions. Adding reload means defining reload→sprint, reload→walk, reload→idle, reload→crouch, and the reverse transitions back. With N states, you potentially need N² transitions. Commands have zero transitions because scheduling a command doesn't depend on what other commands ran before. Press reload button, schedule reload command. Gommand provides the ActionTrigger class that handles scheduling commands when buttons are pressed.

- **Automatic conflict resolution**: Gommand is inherently aware of potential conflicts between scheduled commands, the CommandScheduler handles all conflicts automatically based on subsystem requirements.

- **Declarative**: Similar to functional programming, where map, filter, and reduce describe what to do, not how to iterate, Gommand lets you declare behavior with commands like ConditionalCommand, RepeatCommand, and RunCommand, making logic readable and maintainable.

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
