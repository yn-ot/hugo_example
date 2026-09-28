# Thème Dot-Org — copie vendorée

Copie de **cncf/dot-org-hugo-theme v0.1.8** (tag `v0.1.8` → objet tag `fa02c2f6a9cf21c11ff2bac66eba976bcb4f7c30`
→ commit `b73067605e724b8f8ef6323e37437d62c24ba125`, publié le 2025-07-23, licence MIT), vendorée le 2026-09-23
à partir de l'archive <https://github.com/cncf/dot-org-hugo-theme/archive/refs/tags/v0.1.8.zip>
(687 535 octets, sha256 `8e770b5ec40a0a67a29e51ef949b90b5e22560be6964bf3efd8a8940dcf1dcdd`, calculé localement ;
GitHub ne publie pas de somme de contrôle). Le tag a été re-vérifié via l'API GitHub au moment de la copie
(`git/ref/tags/v0.1.8` → `git/tags/fa02c2f6…` → commit `b73067…`).

Aucun Hugo Module, aucun submodule git, aucun `go.mod`, aucun paquet npm : copie simple, `theme = 'dot-org'`.

## Élagué (absent de cette copie, disponible dans l'archive amont)

`exampleSite/` (site de démonstration : `package.json`, `package-lock.json`, `postcss.config.js`, config YAML,
contenu en/es, `data/authors.yaml`), `images/` (captures pour le catalogue de thèmes Hugo), `.vscode/`,
`.gitignore`, `.tool-versions` (Node 22), `netlify.toml`. Conservés : `LICENSE`, `README.md`, `theme.toml`,
`archetypes/`, `assets/`, `layouts/`, `static/` (polices Nunito/Oswald en woff2, favicons, logos, icônes sociales).

## Modifications locales (cette copie EST modifiée)

Le diff complet contre l'amont est dans `LOCAL-PATCHES.diff` : généré depuis un dossier contenant `a/` (archive
amont v0.1.8, racine du thème) et `b/` (cette copie, racine du thème) par
`diff -ruN -x static -x css -x exampleSite -x images -x netlify.toml -x .gitignore -x .tool-versions -x .vscode -x LOCAL-PATCHES.diff -x VENDORED.md a b > LOCAL-PATCHES.diff`
(hors `static/`, `assets/css/` généré, et fichiers élagués ; préfixes `a/` et `b/` de même profondeur, donc
`patch -p1` s'applique depuis la racine du thème). Chaque fichier touché porte un commentaire `MODIFICATION LOCALE`
ou `AJOUT LOCAL`.

| Fichier | Pourquoi |
|---|---|
| `layouts/partials/head/css.html` | **Bloquant.** L'original compile `assets/scss/styles.scss` avec Dart Sass (`transpiler "dartsass"`) puis PostCSS (Node + autoprefixer). Remplacé par le service du CSS pré-compilé `assets/css/styles.css` (empreinte sha512). Ni Dart Sass, ni Node, ni édition extended à l'exécution. |
| `assets/css/styles.css` | **Généré** : `sass --style=compressed --no-source-map assets/scss/styles.scss assets/css/styles.css` avec Dart Sass autonome 1.105.0 (outil externe, non inclus dans le dépôt : https://github.com/sass/dart-sass/releases). À régénérer après toute modification de `assets/scss/`. Perte : autoprefixer (préfixes pour vieux navigateurs) et `params.styles` (variables Sass figées). |
| `assets/scss/_fonts.scss` | `url("/fonts/…")` → `url("../fonts/…")` : sous un sous-chemin GitHub Pages (`/<repo>/`), les polices étaient cherchées à la racine de l'hôte. |
| `assets/scss/_local.scss` + `styles.scss` (`@use "local"`) | Styles des ajouts : couvertures, agenda, blocs de l'accueil, `min-width: 0` sur les éléments de grille (image 1200 px sur mobile), espacement du menu (6 entrées + titre en texte). |
| `layouts/partials/head/preload.html` | `/fonts/…` → `{{ "fonts/…" \| relURL }}` (sous-chemin). |
| `layouts/partials/header.html`, `footer.html` | Lien du titre/logo `{{ "/" \| absLangURL }}` (= racine de l'hôte) → `{{ site.Home.RelPermalink }}` ; `aria-label` du bouton hamburger en français. Dans `footer.html`, texte de repli du pied de page en français (« © <année> <titre du site> ») quand la clé `copyright` de la configuration est vide (l'original affiche un texte anglais avec un lien vers le thème). |
| `layouts/shortcodes/button.html` | `href` passé par `relURL` ; écrire `link="services/"` **sans barre initiale**. |
| `layouts/partials/blog/byline.html` | Date `January 2, 2006` (anglais) → `time.Format ":date_long"` (« 18 septembre 2026 ») ; `.Site.Data` (déprécié 0.156) → `hugo.Data`. |
| `layouts/blog/list.html`, `blog/single.html` | Image de couverture (`image` ou `featured_image`, ressource du bundle) via `partials/cover.html` ; variables inutilisées retirées. |
| `layouts/404.html`, `layouts/_default/rss.xml` | Textes en français. |
| `layouts/partials/page-title.html` (ajout), `layouts/_default/baseof.html`, `layouts/partials/head.html` | Le titre de la page 404 est codé en dur en anglais dans Hugo (« 404 Page not found », ni config ni i18n) : `<h1>` et `<title>` passent par le partial, qui substitue `i18n "not_found_title"` sur la 404 ; `head.html` n'émet pas les cartes OpenGraph/Twitter (qui répètent `.Title`) sur cette page. |
| `i18n/fr.toml` (ajout) | `breadcrumb_home`, `by`, `social_link_title`, `not_found_title` : le thème amont n'a aucun dossier `i18n/`. |
| `layouts/index.html` (ajout) | Accueil : contenu de `content/_index.md` puis trois blocs (horaires depuis `params.horaires` et adresse depuis `params.adresse`, carte omise si les deux sont vides ; 3 dernières actualités ; 3 prochains événements). Sans lui, `_default/list.html` listerait les pages de premier niveau sous le texte. |
| `layouts/evenements/list.html`, `evenements/single.html`, `partials/event-meta.html`, `partials/event-item.html` (ajouts) | Agenda : le thème n'a pas de type « événement ». Lit `event_date`, `event_end`, `lieu` ; à venir (croissant) puis passés (décroissant) ; « maintenant » = moment de la construction. |
| `layouts/partials/cover.html` (ajout) | Couverture d'un bundle (`image` ou `featured_image`, redimensionnée à 800 px dans les listes, jpeg/png/webp). |
| `layouts/services/single.html` (ajout) | Page Services : le corps de `content/services/index.md` est l'introduction, puis une grille de cartes lue dans le front matter `params.cartes` (liste d'objets `titre`, `texte`), puis `params.suite` (markdown). Plus aucun shortcode `cards`/`card` dans le contenu : les cartes s'éditent comme un formulaire dans le CMS. |

Non modifié (WARN restant sur Hugo 0.166) : `layouts/partials/language-selector.html` appelle `.Site.Languages`
(déprécié 0.156, ERREUR de construction prévue vers Hugo 0.171 — issue amont #79). Version d'Hugo épinglée
par `.hugo-version`.

## Mettre à jour le thème

Télécharger la nouvelle archive, remplacer `archetypes/ assets/ layouts/ static/ LICENSE README.md theme.toml`,
ré-appliquer le diff **depuis la racine du thème** : `cd themes/dot-org && patch -p1 < LOCAL-PATCHES.diff`
(répété à blanc sur une copie vierge de v0.1.8 : s'applique sans rejet et redonne exactement cette copie, `assets/css/`
et `static/` exclus ; sur une version amont plus récente, s'attendre à des rejets à résoudre à la main),
recompiler `assets/css/styles.css`, reconstruire.
