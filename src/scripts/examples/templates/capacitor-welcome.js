window.customElements.define('capacitor-welcome', class extends HTMLElement {
  constructor() {
    super();

    Capacitor.Plugins.SplashScreen.hide();
    
    const root = this.attachShadow({ mode: 'open' });

    root.innerHTML = `
    <style>
      :host {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
        display: block;
        width: 100%;
        height: 100%;
      }
      h1, h2, h3, h4, h5 {
        text-transform: uppercase;
      }
      .button {
        display: inline-block;
        padding: 10px;
        background-color: #73B5F6;
        color: #fff;
        font-size: 0.9em;
        border: 0;
        border-radius: 3px;
        text-decoration: none;
        cursor: pointer;
      }
      main {
        padding: 15px;
      }
      main hr { height: 1px; background-color: #eee; border: 0; }
      main h1 {
        font-size: 1.4em;
        text-transform: uppercase;
        letter-spacing: 1px;
      }
      main h2 {
        font-size: 1.1em;
      }
      main h3 {
        font-size: 0.9em;
      }
      main p {
        color: #333;
      }
      main pre {
        white-space: pre-line;
      }
    </style>
    <div>
      <capacitor-welcome-titlebar>
        <h1>Capacitor</h1>
      </capacitor-welcome-titlebar>
      <main>
        <p>
          <button class="button" id="short-url">short-url</button>
        </p>
        <p>
          <button class="button" id="share-sheet">share-sheet</button>
        </p>
        <p>
          <button class="button" id="standard-events">standard-events</button>
          <button class="button" id="send-event">send-event</button>
          <button class="button" id="send-standard-event">send-standard-event</button>
        </p>
        <p>
          <button class="button" id="disable-tracking-null">disable-tracking null</button>
          <button class="button" id="disable-tracking-true">disable-tracking true</button>
          <button class="button" id="disable-tracking-false">disable-tracking false</button>
        </p>
        <p>
          <button class="button" id="set-identity">set-identity</button>
        </p>
        <p>
          <button class="button" id="logout">logout</button>
        </p>
        <p>
          <img id="image" style="max-width: 100%">
        </p>
      </main>
    </div>
    `
  }

  connectedCallback() {
    const self = this;

    self.shadowRoot.querySelector('#share-sheet').addEventListener('click', function (e) {
      // optional fields
      var analytics = {
        channel: 'facebook',
        feature: 'onboarding',
        campaign: 'content 9 launch',
        stage: 'new user',
        tags: ['one', 'two', 'three']
      }

      // optional fields
      var properties = {
        $desktop_url: 'http://www.example.com/desktop',
        $android_url: 'http://www.example.com/android',
        $ios_url: 'http://www.example.com/ios',
        $ipad_url: 'http://www.example.com/ipad',
        $match_duration: 999,
        custom_string: 'data',
        custom_integer: Date.now(),
        custom_boolean: true
      }

      var shareText = 'Check out this link'

      Capacitor.Plugins.BranchDeepLinks.showShareSheet({ analytics, properties, shareText }).then(function (response) {
        console.log('succes showShareSheet');
        console.log(response);
      }).catch(function (error) {
        console.log('fail showShareSheet');
        console.log(error);
      });
    });

    self.shadowRoot.querySelector('#short-url').addEventListener('click', function (e) {
      // optional fields
      var analytics = {
        channel: 'facebook',
        feature: 'onboarding',
        campaign: 'content 9 launch',
        stage: 'new user',
        tags: ['one', 'two', 'three']
      }

      // optional fields
      var properties = {
        $desktop_url: 'http://www.example.com/desktop',
        $android_url: 'http://www.example.com/android',
        $ios_url: 'http://www.example.com/ios',
        $ipad_url: 'http://www.example.com/ipad',
        $match_duration: 999,
        custom_string: 'data',
        custom_integer: Date.now(),
        custom_boolean: true
      }
      Capacitor.Plugins.BranchDeepLinks.generateShortUrl({ analytics, properties }).then(function (response) {
        console.log('succes generateShortUrl');
        console.log(response);
      }).catch(function (error) {
        console.log('fail generateShortUrl');
        console.log(error);
      });
    });

    self.shadowRoot.querySelector('#standard-events').addEventListener('click', function (e) {
      Capacitor.Plugins.BranchDeepLinks.getStandardEvents().then(function (response) {
        console.log('succes getStandardEvents');
        console.log(response);
      }).catch(function (error) {
        console.log('fail getStandardEvents');
        console.log(error);
      });
    });

    self.shadowRoot.querySelector('#send-event').addEventListener('click', function (e) {
      Capacitor.Plugins.BranchDeepLinks.sendBranchEvent({ eventName: 'clickedonthat' }).then(function (response) {
        console.log('succes sendBranchEvent');
        console.log(response);
      }).catch(function (error) {
        console.log('fail sendBranchEvent');
        console.log(error);
      });
    });

    self.shadowRoot.querySelector('#send-standard-event').addEventListener('click', function (e) {
      var metaData = {
        customerEventAlias: 'alias name for event',
        transactionID: '9994455',
        currency: 'USD',
        revenue: 1.9,
        shipping: 10.9,
        tax: 12.9,
        coupon: 'test_coupon',
        affiliation: 'test_affiliation',
        description: 'Test add to cart event',
        searchQuery: 'test keyword',
        customData: {
          "Custom_Event_Property_Key1": "Custom_Event_Property_val1",
          "Custom_Event_Property_Key2": "Custom_Event_Property_val2"
        }
      };
      Capacitor.Plugins.BranchDeepLinks.sendBranchEvent({ eventName: 'ADD_TO_CART', metaData }).then(function (response) {
        console.log('succes sendBranchEvent');
        console.log(response);
      }).catch(function (error) {
        console.log('fail sendBranchEvent');
        console.log(error);
      });
    });

    self.shadowRoot.querySelector('#disable-tracking-null').addEventListener('click', function (e) {
      Capacitor.Plugins.BranchDeepLinks.disableTracking().then(function (response) {
        console.log('succes disableTracking');
        console.log(response);
      }).catch(function (error) {
        console.log('fail disableTracking');
        console.log(error);
      });
    });

    self.shadowRoot.querySelector('#disable-tracking-true').addEventListener('click', function (e) {
      Capacitor.Plugins.BranchDeepLinks.disableTracking({ isEnabled: true }).then(function (response) {
        console.log('succes disableTracking');
        console.log(response);
      }).catch(function (error) {
        console.log('fail disableTracking');
        console.log(error);
      });
    });

    self.shadowRoot.querySelector('#disable-tracking-false').addEventListener('click', function (e) {
      Capacitor.Plugins.BranchDeepLinks.disableTracking({ isEnabled: false }).then(function (response) {
        console.log('succes disableTracking');
        console.log(response);
      }).catch(function (error) {
        console.log('fail disableTracking');
        console.log(error);
      });
    });

    self.shadowRoot.querySelector('#set-identity').addEventListener('click', function (e) {
      Capacitor.Plugins.BranchDeepLinks.setIdentity({ newIdentity: '1234' }).then(function (referringParams) {
        console.log('succes setIdentity');
        console.log(referringParams);
      }).catch(function (error) {
        console.log('fail setIdentity');
        console.log(error);
      });
    });

    self.shadowRoot.querySelector('#logout').addEventListener('click', function (e) {
      Capacitor.Plugins.BranchDeepLinks.logout().then(function (response) {
        console.log('succes logout');
        console.log(response);
      }).catch(function (error) {
        console.log('fail logout');
        console.log(error);
      });
    });

    Capacitor.Plugins.BranchDeepLinks.addListener('init', (event) => {
      // Retrieve deeplink keys from 'referringParams' and evaluate the values to determine where to route the user
      // Check '+clicked_branch_link' before deciding whether to use your Branch routing logic
      console.log('initialized');
      console.log(event.referringParams);
    });

    Capacitor.Plugins.BranchDeepLinks.addListener('initError', (error) => {
      console.log('error initializing');
      console.error(error);
    });
  }
});

window.customElements.define('capacitor-welcome-titlebar', class extends HTMLElement {
  constructor() {
    super();
    const root = this.attachShadow({ mode: 'open' });
    root.innerHTML = `
    <style>
      :host {
        position: relative;
        display: block;
        padding: 15px 15px 15px 15px;
        text-align: center;
        background-color: #73B5F6;
      }
      ::slotted(h1) {
        margin: 0;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
        font-size: 0.9em;
        font-weight: 600;
        color: #fff;
      }
    </style>
    <slot></slot>
    `;
  }
});
