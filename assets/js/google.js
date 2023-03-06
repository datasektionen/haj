/* exported gapiLoaded */
/* exported gisLoaded */
/* exported handleAuthClick */
/* exported handleSignoutClick */

const API_KEY = 'AIzaSyB08wPGZ-HNSzRR7y59kOJbe1Dxfm5iaP8';

// TODO(developer): Replace with your own project number from console.developers.google.com.
const APP_ID = 'metaspexet-haj';

let accessToken = null;

/**
 *  Sign out the user upon button click.
 */
function handleSignoutClick() {
    if (accessToken) {
        accessToken = null;
        google.accounts.oauth2.revoke(accessToken);
    }
}

let AuthorizeGoogle = {
    mounted() {
        /**
         *  Sign in the user upon button click.
         */
        this.el.addEventListener("click", e => {
            tokenClient.callback = async (response) => {
                if (response.error !== undefined) {
                    throw (response);
                }
                accessToken = response.access_token;
                await createPicker();
            };

            if (accessToken === null) {
                // Prompt the user to select a Google Account and ask for consent to share their data
                // when establishing a new session.
                tokenClient.requestAccessToken({ prompt: 'consent' });
            } else {
                // Skip display of account chooser and consent dialog for an existing session.
                tokenClient.requestAccessToken({ prompt: '' });
            }
        })
    }
}

async function createPicker() {
    const view = new google.picker.DocsView()
        .setEnableDrives(true)
        .setMimeTypes('application/vnd.google-apps.folder')
        .setSelectFolderEnabled(true)
        .setIncludeFolders(true)


    const picker = new google.picker.PickerBuilder()
        .enableFeature(google.picker.Feature.NAV_HIDDEN)
        .setDeveloperKey(API_KEY)
        .setAppId(APP_ID)
        .setOAuthToken(accessToken)
        .addView(view)
        .addView(new google.picker.DocsUploadView())
        .setCallback(pickerCallback)
        .build();

    picker.setVisible(true);
}


/**
 * Displays the file details of the user's selection.
 * @param {object} data - Containers the user selection from the picker
 */
async function pickerCallback(data) {
    if (data.action === google.picker.Action.PICKED) {
        const document = data[google.picker.Response.DOCUMENTS][0];
        const fileId = document[google.picker.Document.ID];
        console.log(document, fileId);
    }
}

export { AuthorizeGoogle }