import { SplashScreen } from '@capacitor/splash-screen';
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
        margin: 5px;
      }
      main {
        padding: 15px;
      }
      main h1 {
        font-size: 1.4em;
        text-transform: uppercase;
        letter-spacing: 1px;
      }
      main h2 {
        font-size: 1.1em;
      }
      main p {
        color: #333;
      }
      #output {
        background: #f5f5f5;
        padding: 10px;
        margin: 10px 0;
        border-radius: 5px;
        font-family: monospace;
        font-size: 0.9em;
        max-height: 300px;
        overflow-y: auto;
      }
    </style>
    <div>
      <capacitor-welcome-titlebar>
        <h1>Branch CocoaPods Test</h1>
      </capacitor-welcome-titlebar>
      <main>
        <h2>Branch Capacitor Plugin (CocoaPods)</h2>
        <p>
          <button class="button" id="generate-branch-url">Generate Branch URL</button>
          <button class="button" id="send-branch-event">Send Branch Event</button>
          <button class="button" id="set-identity">Set Identity</button>
          <button class="button" id="logout">Logout</button>
        </p>
        <div id="output">
          <div>Ready to test Branch SDK...</div>
        </div>
      </main>
    </div>
    `;
    }

    connectedCallback() {
      const self = this;
      const output = self.shadowRoot.querySelector('#output');

      const log = (message) => {
        const div = document.createElement('div');
        div.textContent = `${new Date().toLocaleTimeString()}: ${message}`;
        output.appendChild(div);
        output.scrollTop = output.scrollHeight;
      };

      self.shadowRoot.querySelector('#generate-branch-url').addEventListener('click', async function () {
        try {
          log('Generating Branch URL...');
          const result = await BranchDeepLinks.generateShortUrl({
            channel: 'app',
            feature: 'sharing',
            campaign: 'test-campaign',
          });
          log(`✅ Generated URL: ${result.url}`);
        } catch (error) {
          log(`❌ Error: ${error.message}`);
        }
      });

      self.shadowRoot.querySelector('#send-branch-event').addEventListener('click', async function () {
        try {
          log('Sending Branch event...');
          await BranchDeepLinks.sendBranchEvent({
            eventName: 'PURCHASE',
            metaData: {
              revenue: 19.99,
              currency: 'USD',
              transactionID: 'trans_' + Date.now(),
            },
          });
          log('✅ Event sent successfully');
        } catch (error) {
          log(`❌ Error: ${error.message}`);
        }
      });

      self.shadowRoot.querySelector('#set-identity').addEventListener('click', async function () {
        try {
          log('Setting identity...');
          await BranchDeepLinks.setIdentity({
            newIdentity: 'testUser123',
          });
          log('✅ Identity set to: testUser123');
        } catch (error) {
          log(`❌ Error: ${error.message}`);
        }
      });

      self.shadowRoot.querySelector('#logout').addEventListener('click', async function () {
        try {
          log('Logging out...');
          await BranchDeepLinks.logout();
          log('✅ Logged out successfully');
        } catch (error) {
          log(`❌ Error: ${error.message}`);
        }
      });

      // Listen for Branch init
      BranchDeepLinks.addListener('init', (event) => {
        log('🔔 Branch initialized');
        log(`Referring params: ${JSON.stringify(event.referringParams)}`);
      });

      BranchDeepLinks.addListener('initError', (error) => {
        log(`🔔 Branch init error: ${error.error}`);
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
