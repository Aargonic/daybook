package app.daybook.launcher;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Bundle;
import android.widget.Toast;

import java.util.List;

/**
 * Opens the Daybook page on claude.ai in a Chrome Custom Tab. A Custom Tab
 * shares the browser's claude.ai sign-in (Google sign-in included), camera
 * file picker and storage, which an embedded WebView would not.
 */
public class LaunchActivity extends Activity {
    private static final String URL = "https://claude.ai/artifact/2eDoezjH1GNPbySikQoJc3";
    private static final String EXTRA_SESSION = "android.support.customtabs.extra.SESSION";
    private static final String EXTRA_TOOLBAR_COLOR = "android.support.customtabs.extra.TOOLBAR_COLOR";
    private static final String EXTRA_TITLE_VISIBILITY = "android.support.customtabs.extra.TITLE_VISIBILITY";
    private static final String EXTRA_SHARE_STATE = "androidx.browser.customtabs.extra.SHARE_STATE";
    private static final String CUSTOM_TABS_SERVICE = "android.support.customtabs.action.CustomTabsService";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Uri uri = Uri.parse(URL);

        Intent tab = new Intent(Intent.ACTION_VIEW, uri);
        Bundle session = new Bundle();
        session.putBinder(EXTRA_SESSION, null);
        tab.putExtras(session);
        tab.putExtra(EXTRA_TOOLBAR_COLOR, 0xFF14151C);
        tab.putExtra(EXTRA_TITLE_VISIBILITY, 1);
        tab.putExtra(EXTRA_SHARE_STATE, 2);
        String browser = customTabsBrowser();
        if (browser != null) tab.setPackage(browser);

        try {
            startActivity(tab);
        } catch (ActivityNotFoundException e) {
            try {
                startActivity(new Intent(Intent.ACTION_VIEW, uri));
            } catch (ActivityNotFoundException e2) {
                Toast.makeText(this, "Install a web browser such as Chrome to open Daybook.", Toast.LENGTH_LONG).show();
            }
        }
        finish();
    }

    /** Prefer Chrome, then any other browser that supports Custom Tabs. */
    private String customTabsBrowser() {
        PackageManager pm = getPackageManager();
        List<ResolveInfo> services = pm.queryIntentServices(new Intent(CUSTOM_TABS_SERVICE), 0);
        String first = null;
        for (ResolveInfo info : services) {
            String pkg = info.serviceInfo.packageName;
            if ("com.android.chrome".equals(pkg)) return pkg;
            if (first == null) first = pkg;
        }
        return first;
    }
}
