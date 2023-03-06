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

        let hook = this;

        async function pickerCallback(data) {
            if (data.action === google.picker.Action.PICKED) {
                const document = data[google.picker.Response.DOCUMENTS][0];
                const fileId = document[google.picker.Document.ID];
                hook.pushEventTo(
                    hook.el,
                    "folder_selected",
                    { file_id: fileId }
                );
            }
        }

        this.handleEvent(
            "create_clientside_picker",
            (data) => {
                createPicker(data.token, pickerCallback)
            }
        )
    }
}

async function createPicker(token, callback) {
    const view = new google.picker.DocsView()
        .setEnableDrives(true)
        .setMimeTypes('application/vnd.google-apps.folder')
        .setSelectFolderEnabled(true)
        .setIncludeFolders(true)


    const picker = new google.picker.PickerBuilder()
        .enableFeature(google.picker.Feature.NAV_HIDDEN)
        .setDeveloperKey(API_KEY)
        .setAppId(APP_ID)
        .setOAuthToken(token)
        .addView(view)
        .addView(new google.picker.DocsUploadView())
        .setCallback(callback)
        .build();

    picker.setVisible(true);
}


export { AuthorizeGoogle }