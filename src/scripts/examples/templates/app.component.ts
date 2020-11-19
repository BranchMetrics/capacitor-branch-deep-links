import { Component } from '@angular/core';
import { Plugins } from '@capacitor/core';

import { Platform } from '@ionic/angular';
import { SplashScreen } from '@ionic-native/splash-screen/ngx';
import { StatusBar } from '@ionic-native/status-bar/ngx';

const { BranchDeepLinks } = Plugins;

@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
  styleUrls: ['app.component.scss'],
})
export class AppComponent {
  constructor(
    private platform: Platform,
    private splashScreen: SplashScreen,
    private statusBar: StatusBar,
  ) {
    this.initializeApp();
  }

  initializeApp() {
    this.platform.ready().then(() => {
      this.statusBar.styleDefault();
      this.splashScreen.hide();
      // Branch initialization
      BranchDeepLinks.addListener('init', (event: any) => {
        // Retrieve deeplink keys from 'referringParams' and evaluate the values to determine where to route the user
        // Check '+clicked_branch_link' before deciding whether to use your Branch routing logic
        console.log('initialized');
        console.log(event.referringParams);
      });

      BranchDeepLinks.addListener('initError', (error: any) => {
        console.error(error);
      });
    });
  }
}
