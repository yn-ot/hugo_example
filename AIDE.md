# Aide — un problème ?

Cherchez ce que vous voyez dans la colonne de gauche, puis faites ce qui est indiqué à droite. Si rien ne marche : demandez de l'aide en montrant la fenêtre (ou l'écran), sans la fermer.

## Au lancement (fenêtre noire / Terminal)

| Ce que vous voyez | Ce qu'il faut faire |
|---|---|
| « Le site tourne déjà (une autre fenêtre de lancement est ouverte). Ouverture de l'éditeur… » | C'est normal : le site était déjà lancé, l'éditeur s'ouvre. Vous pouvez fermer la fenêtre en trop. |
| « ERREUR : le port 1313 est déjà utilisé par un autre programme » | Fermez l'autre fenêtre de lancement ou le programme qui utilise ce port, puis relancez. Windows : Gestionnaire des tâches (Ctrl+Maj+Échap) → cherchez `hugo` → Fin de tâche. Mac : fermez toutes les fenêtres Terminal. |
| « ATTENTION : Chrome ou Edge n'a pas été trouvé » | Installez Chrome ou Edge, puis ouvrez `http://127.0.0.1:1313/admin/` dans ce navigateur. L'éditeur ne fonctionne pas dans Firefox ni Safari. |
| « ERREUR : téléchargement impossible » | Vérifiez votre connexion Internet (ou changez de réseau : certains réseaux, d'école ou d'entreprise, bloquent le téléchargement), puis relancez. |
| « ERREUR : le fichier téléchargé est corrompu ou modifié » | Relancez simplement le script. Si l'erreur revient, demandez de l'aide. |
| « ERREUR : Hugo s'est arrêté tout de suite » | Lisez les lignes juste au-dessus : elles nomment le fichier en cause, souvent un article dont l'en-tête est abîmé. Corrigez-le (ou supprimez-le) puis relancez ; sinon demandez de l'aide en montrant la fenêtre. |
| « ERREUR : Hugo s'est arrêté avec le code N » (Windows, en cours d'utilisation) | Lisez les lignes au-dessus du message rouge : c'est souvent une erreur dans un texte que vous venez d'enregistrer. Corrigez-le puis relancez ; sinon demandez de l'aide en montrant la fenêtre. |
| « ERREUR : le site ne répond pas après 60 secondes » | Fermez la fenêtre, relancez. Si cela persiste, demandez de l'aide. |
| « ERREUR : le fichier .hugo-version est introuvable… » | Le projet est incomplet : dans GitHub Desktop, faites Pull ; si le fichier manque toujours, demandez de l'aide. |
| « ERREUR : le fichier .hugo-version est invalide (« … ») » | Le fichier a été modifié par erreur : dans GitHub Desktop, annulez les changements sur `.hugo-version` (clic droit → Discard changes) puis faites Pull ; sinon demandez de l'aide. |
| Windows : « Le lancement a echoue. Lisez le message ci-dessus, puis fermez cette fenetre. » | Lisez le message au-dessus (la ligne rouge « ERREUR : … » et cherchez-la dans ce tableau), puis relancez ; si l'erreur persiste, demandez de l'aide en montrant la fenêtre. |
| « Le fichier scripts/start.sh est introuvable » (Mac) | Le projet est incomplet : dans GitHub Desktop, faites Pull, puis relancez. |
| Windows : « Windows a protégé votre ordinateur » (SmartScreen) | **Informations complémentaires** → **Exécuter quand même**. |
| Mac : « Terminal souhaite accéder à Documents / Bureau… » | **Autoriser**. |
| Mac : « impossible d'ouvrir start.command » | Réglages Système → **Confidentialité et sécurité** → descendez jusqu'au message → **Ouvrir quand même** (dans l'heure qui suit), puis relancez. |
| Mac : rien ne se passe au double-clic | Clic droit sur `start.command` → **Ouvrir avec** → **Terminal**. |

## Dans l'éditeur (CMS)

| Ce que vous voyez | Ce qu'il faut faire |
|---|---|
| « Le dossier sélectionné n'est pas un répertoire racine de dépôt » (en anglais : « not a repository root directory »), ou l'éditeur refuse le dossier | Vous avez choisi un sous-dossier. Choisissez le dossier du projet lui-même, celui qui contient le dossier caché `.git`. |
| L'éditeur ouvre le **mauvais projet** (les articles d'un autre site) | Menu **Compte** (en haut à droite) → **Se déconnecter**, puis **Travailler avec un dépôt local** → choisissez à nouveau le bon dossier. |
| L'éditeur redemande l'accès au dossier à chaque fois | C'est normal dans certains navigateurs : cliquez sur **Autoriser** ; choisissez « Autoriser à chaque visite » si c'est proposé. |
| Interface en **anglais**, icônes remplacées par des mots | Connectez-vous à Internet, puis rechargez la page (F5). La première ouverture de l'éditeur a besoin d'Internet. |
| Mes modifications faites sur un autre ordinateur n'apparaissent pas | GitHub Desktop → **Pull**, puis rechargez la page de l'éditeur (F5). |
| J'ai modifié un fichier ailleurs (GitHub Desktop, éditeur de texte) et l'éditeur ne le voit pas | Rechargez la page de l'éditeur (F5). |
| Le texte que je tape n'apparaît pas dans l'aperçu `http://127.0.0.1:1313/` | Cliquez sur **Enregistrer** dans l'éditeur : l'aperçu se met à jour après l'enregistrement. |

## En ligne (GitHub)

| Ce que vous voyez | Ce qu'il faut faire |
|---|---|
| Onglet Actions en **rouge** à l'étape « Configurer GitHub Pages » (ou e-mail « Deploy: some jobs were not successful » juste après la création) | Settings → **Pages** → Source : **GitHub Actions**, puis Actions → **Deploy** → **Run workflow**. |
| Onglet Actions en **rouge** à une autre étape | Ouvrez l'exécution en rouge (cliquez sur son titre), puis sur l'étape rouge, et lisez le message : souvent un article dont l'en-tête est abîmé. Sinon, demandez de l'aide en montrant ce message. |
| Mon article n'apparaît pas en ligne | Dans l'ordre : la case **Brouillon** est-elle décochée ? La **date** est-elle dans le futur ? Avez-vous fait **Commit** puis **Push** ? La coche verte est-elle apparue dans **Actions** ? Puis rechargez avec **Ctrl+Maj+R** / **Cmd+Maj+R** (jusqu'à 10 minutes de cache). |
| Mon événement n'apparaît plus dans « Prochains événements » | Normal : la liste est calculée au moment de la publication ; un événement dont la date (« Début de l'événement ») est passée bascule dans « Événements passés » à la prochaine publication (Push). |
| Le site en ligne n'a pas de mise en page (texte brut, pas de couleurs) | Attendez la fin du déploiement (coche verte) et rechargez avec Ctrl+Maj+R / Cmd+Maj+R. Si cela persiste, demandez de l'aide. |
| GitHub Desktop dit qu'il y a un **conflit** | Ne cliquez pas au hasard : demandez de l'aide en montrant l'écran. |

## Retirer les métadonnées d'une photo à la main

Les photos prises avec un téléphone contiennent des métadonnées (date, appareil, souvent la **position GPS**). Elles sont publiées avec la photo. Pour les retirer avant d'ajouter la photo :

- **Windows** : clic droit sur la photo → **Propriétés** → onglet **Détails** → **Supprimer les propriétés et les informations personnelles** → « Créer une copie avec toutes les propriétés possibles supprimées » → OK. Utilisez la copie.
- **macOS** : ouvrez la photo dans **Aperçu** → menu **Outils** → **Afficher l'inspecteur** → onglet GPS → **Supprimer les infos de localisation** ; ou, depuis **Photos** : Fichier → **Exporter** → décochez « Informations de localisation ».
