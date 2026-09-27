# Messagerie avec comptes et amis — guide de mise en ligne

Cette appli est indépendante de Claude : chacun crée un compte (e-mail + mot de passe), cherche des amis par pseudo, leur envoie une demande, puis discute avec eux en temps réel.

Deux fichiers :
- `schema.sql` → à exécuter une fois dans Supabase (crée la base de données).
- `index.html` → l'appli elle-même (interface + logique).

Aucun serveur à coder : Supabase fournit la base de données, les comptes et le temps réel ; l'hébergement du site sert juste ce fichier HTML.

## 1. Créer le projet Supabase (gratuit)

1. Allez sur https://supabase.com et créez un compte.
2. « New project » → donnez-lui un nom, un mot de passe de base de données (à garder de côté), et une région proche de vous.
3. Attendez ~2 minutes que le projet soit prêt.

## 2. Créer les tables

1. Dans le menu de gauche, ouvrez **SQL Editor** → **New query**.
2. Collez tout le contenu de `schema.sql` et cliquez sur **Run**.
3. Vérifiez dans **Table Editor** que les tables `profiles`, `friendships` et `messages` existent.

## 3. Récupérer vos clés

1. Menu **Project Settings** → **API**.
2. Copiez **Project URL** et la clé **anon public**.
3. Ouvrez `index.html` et remplacez, tout en haut du `<script>` :
   ```js
   const SUPABASE_URL = "https://VOTRE-PROJET.supabase.co";
   const SUPABASE_ANON_KEY = "VOTRE_CLE_ANON_PUBLIQUE";
   ```

## 4. (Recommandé) Désactiver la confirmation par e-mail pour tester vite

Par défaut Supabase envoie un e-mail de confirmation à l'inscription. Pour tester tout de suite entre amis sans configurer l'envoi d'e-mails :
- **Authentication** → **Providers** → **Email** → désactivez « Confirm email ».
- Vous pourrez le réactiver plus tard si vous voulez une vraie confirmation par e-mail.

## 5. Mettre le site en ligne

La façon la plus simple, sans rien installer :

1. Allez sur https://app.netlify.com/drop
2. Glissez-déposez juste le fichier `index.html` (renommé si besoin, ça marche tel quel).
3. Netlify vous donne un lien du type `https://un-nom-au-hasard.netlify.app`.

C'est ce lien que vous partagez à vos amis — chacun y crée son propre compte.

(Alternative équivalente : Vercel, GitHub Pages, ou tout hébergeur de fichiers statiques.)

## 6. Utiliser l'appli

1. Chaque personne ouvre le lien, clique sur « Créer un compte », choisit un pseudo, un e-mail et un mot de passe.
2. Dans la barre de recherche à gauche, on cherche le pseudo d'un ami et on clique « Ajouter ».
3. L'autre personne voit la demande dans « Demandes reçues » et clique « Accepter ».
4. Une fois amis, on clique sur son nom dans la liste pour discuter — les messages arrivent en direct des deux côtés.

## 7. Nouvelles fonctionnalités

**Paramètres** (icône ⚙️ à côté de votre nom) :
- Changer de thème : blanc, noir, orange, rouge, jaune (mémorisé sur cet appareil).
- Se déconnecter.
- Supprimer son compte (supprime le profil, les amis et les messages liés — voir limite ci-dessous).

**Fond d'écran par conversation** : dans une discussion, cliquez sur l'icône 🖼️ en haut à droite pour choisir une couleur ou importer une image depuis votre appareil (mémorisé sur cet appareil, pour cette conversation).

**Devenir administrateur** : créez d'abord votre compte normalement dans l'appli, puis dans Supabase → SQL Editor, exécutez (en remplaçant par votre pseudo) :
```sql
update public.profiles set is_admin = true where username = 'votre_pseudo';
```
Un lien « Panneau administrateur » apparaît alors dans vos paramètres, avec :
- La liste de tous les comptes (pseudo, statut administrateur, banni ou non).
- Un bouton pour bannir / débannir un compte (un compte banni est déconnecté et ne peut plus se reconnecter).

**Ce que le panneau administrateur ne peut pas faire, volontairement :**
- Voir les mots de passe : Supabase ne les stocke jamais en clair, personne ne peut les récupérer, même vous.
- Se connecter instantanément au compte de quelqu'un d'autre : cela demanderait d'exposer une clé secrète dans le code du site, ce qui permettrait à n'importe qui de prendre le contrôle de tous les comptes. Si vous avez vraiment besoin de cette fonctionnalité, il faut un petit serveur séparé qui garde cette clé secrète — dites-le-moi si vous voulez que je vous l'écrive.

## 8. Appels, notifications et messages vocaux

**Messages vocaux** : cliquez sur 🎤 dans la zone de saisie pour démarrer l'enregistrement, cliquez à nouveau (⏹️) pour l'envoyer. Le navigateur demandera l'accès au micro la première fois.

**Notifications** : dans Paramètres → « Activer les notifications », autorisez-les. Un message arrivé pendant que vous êtes sur un autre onglet ou une autre conversation déclenche une notification du navigateur. Limite : ça ne fonctionne que si le navigateur reste ouvert (même en arrière-plan) — pas si l'appli est complètement fermée.

**Appels audio** : cliquez sur 📞 en haut d'une conversation pour appeler cet ami. Il reçoit une fenêtre d'appel entrant avec accepter/refuser. Limites : audio uniquement (pas de vidéo), et les deux personnes doivent avoir l'appli ouverte dans leur navigateur au même moment — ce n'est pas un vrai appel téléphonique qui sonne appli fermée.

## Limites à connaître

- Les messages ne sont pas chiffrés de bout en bout (Supabase les stocke en clair, protégés par les règles d'accès qui limitent la lecture à l'expéditeur et au destinataire).
- Pas de pièces jointes, de fils de discussion ni de groupes dans cette version — uniquement des messages privés entre deux amis.
- Le plan gratuit de Supabase convient très bien pour un usage entre amis ; au-delà de plusieurs milliers d'utilisateurs actifs il faudra passer à un plan payant.

Je peux ajouter des groupes, des photos de profil, des messages vocaux ou la suppression de messages si vous voulez aller plus loin.
