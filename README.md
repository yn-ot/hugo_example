# Mon site

> **Ce dépôt est public.** N'y mettez rien de personnel ou de confidentiel, même en brouillon : tout l'historique est visible. Vous pourrez supprimer le dépôt plus tard (les copies déjà faites par d'autres restent).
>
> **Photos** : les photos gardent leurs métadonnées (dont la position GPS de la prise de vue) et sont publiées telles quelles. Retirez ces métadonnées avant d'ajouter une photo (comment faire : voir [AIDE.md](AIDE.md)). Ne publiez pas de photo d'autrui sans accord.

Un problème ? → [AIDE.md](AIDE.md).

## Il vous faut

- un compte GitHub ;
- **Chrome ou Edge** (pas Firefox, pas Safari ; Brave : activer `brave://flags/#file-system-access-api`) ;
- **GitHub Desktop**, connecté à votre compte GitHub ;
- **une connexion Internet à la première ouverture de l'éditeur** (sinon il s'affiche en anglais, sans icônes).

Rien d'autre : Hugo est téléchargé automatiquement au premier lancement.

## Une seule fois

1. Sur GitHub, en haut de cette page : **Use this template** → **Create a new repository** → visibilité **Public** → **Create repository**.
2. Dans votre nouveau dépôt : **Settings** → **Pages** → Source : **GitHub Actions**.
3. **Code** → **Open with GitHub Desktop** → clonez le dépôt dans un dossier normal de votre ordinateur (pas OneDrive, Dropbox ou iCloud ; pas WSL).
4. Onglet **Actions** → workflow **Deploy** → **Run workflow** → attendez la coche verte.
5. L'adresse de votre site est affichée dans **Settings → Pages** (elle se termine par le nom de votre dépôt).

> Si vous recevez un e-mail « Deploy: some jobs were not successful » juste après la création, c'est normal : refaites l'étape 2 (Settings → Pages), puis l'étape 4 (Run workflow).

## Pour travailler sur le site

1. **GitHub Desktop** → **Fetch origin** / **Pull** (surtout si vous changez d'ordinateur).
2. Double-cliquez sur `scripts/start.bat` (Windows) ou `scripts/start.command` (Mac). Une fenêtre noire (Windows) ou une fenêtre Terminal (Mac) s'ouvre, puis l'éditeur dans Chrome ou Edge.
3. Dans l'éditeur : **Travailler avec un dépôt local** → choisissez le dossier du projet (celui qui contient le dossier caché `.git`) → **Autoriser** (choisissez « Autoriser à chaque visite » si c'est proposé).
4. Écrivez vos actualités, vos événements et vos sélections. L'aperçu de votre site est sur `http://127.0.0.1:1313/` et se recharge tout seul.
5. **GitHub Desktop** → relisez les changements → écrivez un message → **Commit to main** → **Push origin**.
6. Onglet **Actions** : attendez la coche verte, puis rechargez votre site avec **Ctrl+Maj+R** (Windows) ou **Cmd+Maj+R** (Mac). Le changement peut mettre jusqu'à 10 minutes à apparaître.

Pour arrêter : fermez la fenêtre noire (Windows) ou la fenêtre Terminal (Mac ; si une question « Terminer les processus ? » apparaît, répondez oui).

**Le site d'exemple.** Le template arrive rempli avec le site d'une bibliothèque fictive, la « Bibliothèque des Acacias », pour que vous voyiez tout de suite à quoi ressemble un site complet. Tout se renomme depuis l'éditeur :

- **Réglages du site** : titre, description, adresse, horaires, texte du pied de page ;
- **Pages → Page d'accueil** : le texte de bienvenue (et les pages **Services** et **À propos**) ;
- les actualités, événements et sélections d'exemple se suppriment un par un depuis l'éditeur, quand vous avez les vôtres.

## À retenir

> - **Enregistrer dans le CMS (l'éditeur) ≠ publier.** Tant que vous n'avez pas fait Push, rien n'est en ligne.
> - **Brouillon coché = visible seulement chez vous** (case « Brouillon » d'une actualité, d'un événement ou d'une sélection) : regardez l'actualité « Brouillon d'exemple », elle est dans votre aperçu mais pas sur le site en ligne. Un article daté dans le futur n'est pas publié non plus avant sa date.
> - **Après un Pull, rechargez la page du CMS.**

Le code du template est sous licence MIT ; le contenu que vous écrivez vous appartient.
