import { SplashScreen } from '@capacitor/splash-screen';
import { Camera } from '@capacitor/camera';
import { BranchDeepLinks } from 'capacitor-branch-deep-links';

window.customElements.define(
  'capacitor-welcome',
  class extends HTMLElement {
    constructor() {
      super();

      SplashScreen.hide();

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
        <h2>Branch Capacitor Sample App</h2>
        <p>
          <button class="button" id="generate-branch-url">Generate Branch URL</button>
        </p>
        <p>
          <button class="button" id="show-share-sheet">Show Share Sheet</button>
        </p>
        <p>
          <button class="button" id="get-standard-events">Get Standard Events</button>
        </p>
        <p>
          <button class="button" id="send-branch-event">Send Branch Event</button>
        </p>
        <p>
          <button class="button" id="handle-att-authorization-status">Handle ATT Authorization Status</button>
        </p>
        <p>
          <button class="button" id="disable-tracking">Disable Tracking</button>
        </p>
        <p>
          <button class="button" id="set-identity">Set Identity</button>
        </p>
        <p>
          <button class="button" id="logout">Logout</button>
        </p>
        <p>
          <button class="button" id="generate-branch-qr-code">Generate Branch QR Code</button>
        </p>
        <p>
          <button class="button" id="get-latest-referring-params">Get Latest Referring Params</button>
        </p>
        <p>
          <button class="button" id="get-first-referring-params">Get First Referring Params</button>
        </p>
        <p>
          <button class="button" id="set-dma-params-for-eea">Set DMA Params For EEA</button>
        </p>
        <p>
          <button class="button" id="handle-url">Handle URL</button>
        </p>
        <p>
          <button class="button" id="set-consumer-protection-attribution-level">Set Consumer Protection Attribution Level</button>
        </p>
      </main>
    </div>
    `;
    }

    connectedCallback() {
      const self = this;

      self.shadowRoot.querySelector('#send-branch-event').addEventListener('click', async function (e) {
        await sendBranchEvent();
      });

      self.shadowRoot.querySelector('#show-share-sheet').addEventListener('click', async function (e) {
        await showShareSheet();
      });

      self.shadowRoot.querySelector('#get-standard-events').addEventListener('click', async function (e) {
        await getStandardEvents();
      });

      self.shadowRoot.querySelector('#generate-branch-url').addEventListener('click', async function (e) {
        await generateBranchURL();
      });

      self.shadowRoot.querySelector('#handle-att-authorization-status').addEventListener('click', async function (e) {
        await handleATTAuthorizationStatus();
      });

      self.shadowRoot.querySelector('#disable-tracking').addEventListener('click', async function (e) {
        await disableTracking();
      });

      self.shadowRoot.querySelector('#set-identity').addEventListener('click', async function (e) {
        await setIdentity();
      });

      self.shadowRoot.querySelector('#logout').addEventListener('click', async function (e) {
        await logout();
      });

      self.shadowRoot.querySelector('#generate-branch-qr-code').addEventListener('click', async function (e) {
        await generateBranchQRCode();
      });

      self.shadowRoot.querySelector('#get-latest-referring-params').addEventListener('click', async function (e) {
        await getLatestReferringParams();
      });

      self.shadowRoot.querySelector('#get-first-referring-params').addEventListener('click', async function (e) {
        await getFirstReferringParams();
      });

      self.shadowRoot.querySelector('#set-dma-params-for-eea').addEventListener('click', async function (e) {
        await setDMAParamsForEEA();
      });

      self.shadowRoot.querySelector('#handle-url').addEventListener('click', async function (e) {
        await handleURL();
      });

      self.shadowRoot
        .querySelector('#set-consumer-protection-attribution-level')
        .addEventListener('click', async function (e) {
          await setConsumerProtectionAttributionLevel();
        });
    }
  },
);

window.customElements.define(
  'capacitor-welcome-titlebar',
  class extends HTMLElement {
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
  },
);

async function generateBranchURL() {
  try {
    const result = await BranchDeepLinks.generateShortUrl({
      channel: 'app',
      feature: 'sharing',
      campaign: 'test-campaign',
    });
    console.log('Generated Branch URL:', result);
  } catch (error) {
    console.error('Error generating Branch URL:', error);
  }
}

async function showShareSheet() {
  try {
    await BranchDeepLinks.showShareSheet();
  } catch (error) {
    console.error('Error showing share sheet: ', error);
  }
}

async function getStandardEvents() {
  try {
    await BranchDeepLinks.getStandardEvents();
    console.log('Successfully got standard events.');
  } catch (error) {
    console.error('Error getting Branch standard events: ', error);
  }
}

async function sendBranchEvent() {
  try {
    await BranchDeepLinks.sendBranchEvent({
      eventName: 'PURCHASE',
      eventProperties: {
        revenue: 19.99,
        currency: 'USD',
        transactionID: 'trans_' + Date.now(),
        description: 'Product Purchase',
        // Add any custom metadata you need
        customData: {
          productId: 'product_123',
          productName: 'Sample Product',
          quantity: 1,
        },
      },
    });
    console.log('Purchase event sent successfully');
  } catch (error) {
    console.error('Error sending purchase event: ', error);
  }
}

async function handleATTAuthorizationStatus() {
  try {
    await BranchDeepLinks.handleATTAuthorizationStatus({
      status: 0,
    });
    console.log('Successfully modified ATT authorization status.');
  } catch (error) {
    console.error('Error handling ATT Authorization status: ', error);
  }
}

async function disableTracking() {
  try {
    await BranchDeepLinks.disableTracking({
      isEnabled: false,
    });

    console.log('Successfully disabled tracking.');
  } catch (error) {
    console.error('Error disabling Branch tracking: ', error);
  }
}

async function setIdentity() {
  try {
    await BranchDeepLinks.setIdentity({
      newIdentity: 'testIdentity',
    });
    console.log('Successfully set identity to:', newIdentity);
  } catch (error) {
    console.error('Error setting Branch Identity: ', error);
  }
}

async function logout() {
  try {
    await BranchDeepLinks.logout();
    console.log('Successfully logged out.');
  } catch (error) {
    console.error('Error logging out: ', error);
  }
}

async function generateBranchQRCode() {
  try {
    const result = await BranchDeepLinks.getBranchQRCode({
      analytics: {
        channel: 'app',
        feature: 'qr-code',
        campaign: 'qr-campaign',
        stage: 'production',
        tags: ['qr', 'mobile'],
      },
      properties: {
        $desktop_url: 'https://example.com/desktop',
        $ios_url: 'https://example.com/ios',
        custom_data: 'custom_value',
      },
      settings: {
        codeColor: '#000000',
        backgroundColor: '#FFFFFF',
        centerLogo: 'https://cdn.branch.io/branch-assets/1598575682753-og_image.png',
        width: 300,
        margin: 1,
        imageFormat: 'PNG',
      },
    });
    console.log('Successfully generated Branch QR Code:', result.qrCode);
    // The result.qrCode contains a base64 encoded image string
    // You can display it in an img tag: <img src="data:image/png;base64,{result.qrCode}" />
  } catch (error) {
    console.error('Error generating Branch QR Code: ', error);
  }
}

async function getLatestReferringParams() {
  try {
    const result = await BranchDeepLinks.getLatestReferringParams();
    console.log('Latest referring params:', result.referringParams);
  } catch (error) {
    console.error('Error getting latest referring params: ', error);
  }
}

async function getFirstReferringParams() {
  try {
    const result = await BranchDeepLinks.getFirstReferringParams();
    console.log('First referring params:', result.referringParams);
  } catch (error) {
    console.error('Error getting first referring params: ', error);
  }
}

async function setDMAParamsForEEA() {
  try {
    await BranchDeepLinks.setDMAParamsForEEA({
      eeaRegion: true,
      adPersonalizationConsent: true,
      adUserDataUsageConsent: true,
    });
    console.log('Successfully set DMA params for EEA.');
  } catch (error) {
    console.error('Error setting DMA params for EEA: ', error);
  }
}

async function handleURL() {
  try {
    await BranchDeepLinks.handleUrl({
      branch: 'https://bnctestbed.app.link/qnBzO3vAc2b',
    });
    console.log('Successfully handled URL.');
  } catch (error) {
    console.error('Error handling URL: ', error);
  }
}

async function setConsumerProtectionAttributionLevel() {
  try {
    await BranchDeepLinks.setConsumerProtectionAttributionLevel({
      level: 'standard',
    });
    console.log('Successfully set consumer protection attribution level.');
  } catch (error) {
    console.error('Error setting consumer protection attribution level: ', error);
  }
}
