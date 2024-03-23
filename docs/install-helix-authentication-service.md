# Helix Authentication Service installation guide

## [Installation](https://hub.docker.com/r/perforce/helix-auth-svc)

1. Get the official Helix Authentication image :

   ```bash
   docker pull perforce/helix-auth-svc
   ```

2. Create a folder :

   ```bash
   mkdir -p /srv/dockers/helix-authentication && cd /srv/dockers/helix-authentication
   ```

3. Create a .env file containing [Helix Authentication settings](https://www.perforce.com/manuals/helix-auth-svc/Content/HAS/configuring-has.html#Configuring_Helix_Authentication_Service).

   ```bash
   nano .env
   ```

4. Paste the content in your env file and change the SVC_BASE_URI to the service url (e.g https://SRV_IP:3000/).

   ```bash
   SVC_BASE_URI=<YOUR_SVC_BASE_URI>
   PROTOCOL=https
   DEBUG=no
   NODE_ENV=production
   ```

   :warning: Do not add single or double quote in an .env file.
   Now, we need to link Helix Authentication to an Identity Provider.

## Configuration

### [Configure an Identity Provider](https://www.perforce.com/manuals/helix-auth-svc/Content/HAS/example-configs.html#Example_Identity_Provider_configurations)

1. Create an account on [Auth0](https://auth0.com/signup?signUpData=%7B%22category%22%3A%22button%22%7D), it will unify authentication for Helix and other services. Complete all steps depending on your location.

2. In Auth0, create a `Regular Web Application` without specifying the technology. It will allow Helix Authentication to use Auth0 for Authentication.

3. Now, go to Applications > <YOUR_NEWLY_APPLICATION_CREATED> > Settings and keep aside `Client ID` and `Client Secret`, it will be needed for Helix Authentication variables.

4. In `Allowed Callback URLs`, add <YOUR_SVC_BASE_URI>/oidc/callback.

5. In `Allowed Logout URLs`, add <YOUR_SVC_BASE_URI>.

6. Scroll and open `Advanced Settings` section and click on `Endpoints`.

7. Copy `OpenID Configuration` URL and open it in your browser. Keep aside the `issuer` value.

8. Add in your env file the following variables :

   ```bash
   OIDC_ISSUER_URI=<YOUR_ISSUER>
   OIDC_CLIENT_ID=<YOUR_CLIENT_ID>
   OIDC_CLIENT_SECRET=<YOUR_CLIENT_SECRET>
   ```

   :warning: Do not add single or double quote in an .env file.

10. Launch the service :

   ```bash
   docker run -d --env-file .env -p 3000:3000 --name helix-authentication-service --restart=unless-stopped perforce/helix-auth-svc
   ```

   Now we will configure the link with Helix services.

### Configure Helix Core extension

1. In Portainer, open a console in the Helix Core container.

2. Clone the [Helix Authentication extension](https://github.com/perforce/helix-authentication-extension/tree/main) :

   ```bash
   git clone https://github.com/perforce/helix-authentication-extension.git /srv/helix-authentication-extension
   ```

3. Launch the configuration script :

   ```bash
   bash /srv/helix-authentication-extension/bin/configure-login-hook.sh
   ```

4. In configuration steps, override some defaults values :

| Parameter                | Value                      | Details                                                                                                             |
| ------------------------ | -------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Helix Server P4PORT      | <YOUR_HELIX_CORE_PORT>     | NA                                                                                                                  |
| Helix super-user         | <YOUR_SUPER_USER>          | Superuser name of Helix Core                                                                                        |
| Service base URL         | <YOUR_SVC_BASE_URI>        | Helix Authentication Service URL                                                                                    |
| Preferred auth protocol  | NA                         | NA                                                                                                                  |
| Debug logging enabled    | yes                        |                                                                                                                     |
| List of SSO users        | NA                         | Leave blank to apply rule on a group. It's cleaner and easy to maintain.                                            |
| List of SSO groups       | <YOUR_PERFORCE_GROUP_NAME> | User group name which must not contain your superuser (other services will not be able to connect using this name). |
| List of non-SSO users    | <YOUR_SUPER_USER>          | At least one superuser that does not authenticate using SSO to always keep the control.                             |
| List of non-SSO groups   | NA                         | Avoid generic name easily targeted.                                                                                 |
| Name identifier property | email                      | Trigger variable used as unique user identifier, one of: `fullname`, `email`, or `user`.                            |
| Perforce user property   | email                      | Field within identity provider user profile containing unique user identifier.                                      |

1. Say yes to the next question, the configuration script will automatically configure Helix Core variables that are needed by Helix Authentication Service.

2. Now, you can test the extension by typing :

   ```bash
   p4 extension --run loginhook-a1 test-all
   ```

   It will run several tests, a complete description is available [here](https://github.com/perforce/helix-authentication-extension/blob/main/docs/Administrator-Guide.md#testing).

3. If you enabled logging in the extension configuration, you could find them by typing :

   ```bash
   p4 extension --list --type=extensions
   ```

   The path assigned to the `data-dir` field corresponds to the log path (e.g. `P4ROOT/server.extensions.dir/117E9283-732B-45A6-9993-AE64C354F1C5/1-data/log.json`).

4. Login in P4V client with your superuser account and create a new user in <YOUR_PERFORCE_GROUP_NAME>. Create the same user in Auth0 (same email address and password).

5. When the user login, a web browser page will be opened. After completing the form, he will be connected !

## References

- [Helix Authentication Service docker installation](https://hub.docker.com/r/perforce/helix-auth-svc)
- [Helix Authentication Identity Provider configuration](https://www.perforce.com/manuals/helix-auth-svc/Content/HAS/example-configs.html#Example_Identity_Provider_configurations)
- [Helix Authentication environment variables](https://www.perforce.com/manuals/helix-auth-svc/Content/HAS/configuring-has.html#Configuring_Helix_Authentication_Service)
- [Helix Authentication extension for Helix Core](https://github.com/perforce/helix-authentication-extension/tree/main)
- [Helix Authentication configuration script](https://github.com/perforce/helix-authentication-extension/blob/main/docs/Administrator-Guide.md#configuration-script)
- [Helix Authentication testing command](https://github.com/perforce/helix-authentication-extension/blob/main/docs/Administrator-Guide.md#testing)
