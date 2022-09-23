const selector = {
  template: `
    <div>
      <div class="wrapper">
        <div>
          <label for="projectType">Project Type:</label><br>
          <select v-model="projectType" id="projectType">
            <option disabled :value="null">Project Type</option>
            <option v-for="item in projectTypeOptions" :value="item.key">
              {{ item.text }}
            </option>
          </select>
        </div>
        <div>
          <label for="projectName">Project Name:</label><br>
          <input v-model="projectName" id="projectName" placeholder="drupal / feeds / etc" />
          <p>ie: drupal / feeds / etc</p>
        </div>
        <div>
          <label for="coreVersion">Core Version:</label><br>
          <input v-model="coreVersion" id="coreVersion" placeholder="9.4.5">
          <p>ie: 9.4.5</p>
        </div>
        <div>
          <label for="moduleVersion">Module Version:</label><br>
          <input v-model="moduleVersion" id="moduleVersion" placeholder="9.5.x">
          <p>ie: 9.5.x</p>
        </div>
        <div>
          <label for="issueFork">Issue Fork:</label><br>
          <input v-model="issueFork" id="issueFork" placeholder="drupal-3042417" />
          <p>ie: drupal-3042417</p>
        </div>
        <div>
          <label for="issueBranch">Issue Branch:</label><br>
          <input v-model="issueBranch" id="issueBranch" placeholder="3042417-accessible-dropdown-for">
          <p>ie: 3042417-accessible-dropdown-for</p>
        </div>
        <div>
          <label for="patchFile">Patch File:</label><br>
          <input v-model="patchFile" id="patchFile" placeholder="https://www.drupal.org/files/issues/2020-07-17/3042417-100.patch">
          <p>ie: https://www.drupal.org/files/issues/2020-07-17/3042417-100.patch</p>
        </div>
        <div>
          <label for="installProfile">Install Profile<label><br>
          <select v-model="installProfile" id="installProfile">
            <option disabled :value="null">Install Profile</option>
            <option v-for="item in installProfileOptions" :value="item.key">
              {{ item.text }}
            </option>
          </select>
        </div>
      
      <a :href="resultURL" class="button" target="_blank">
        <h2>Open in DrupalPod</h2>
      </a>
      Link used by "Open in DrupalPod" button:
      <div class="code">{{ resultURL }}</div>
    </div>
    `,
  data() {
    return {
      projectTypeOptions: [
        { text: "Core", key: "core" },
        { text: "Module", key: "module" },
        { text: "Theme", key: "theme" }
      ],
      installProfileOptions: [
        { text: "None", key: "" },
        { text: "Minimal", key: "minimal" },
        { text: "Standard", key: "standard" },
        { text: "Umami", kay: "demo_umami" }
      ],
      projectName: "",
      issueFork: "",
      issueBranch: "",
      moduleVersion: "",
      coreVersion: "",
      patchFile: "",
      projectType: "core",
      installProfile: ""
    };
  },
  computed: {
    resultURL() {
      // `this` points to the component instance

      return (
        "https://gitpod.io/#" +
        "DP_PROJECT_TYPE=" +
        this.projectType +
        "," +
        "DP_INSTALL_PROFILE=" +
        this.installProfile +
        "," +
        "DP_PROJECT_NAME=" +
        this.projectName +
        "," +
        "DP_ISSUE_FORK=" +
        this.issueFork +
        "," +
        "DP_ISSUE_BRANCH=" +
        this.issueBranch +
        "," +
        "DP_MODULE_VERSION=" +
        this.moduleVersion +
        "," +
        "DP_CORE_VERSION=" +
        this.coreVersion +
        "," +
        "DP_PATCH_FILE=" +
        this.patchFile +
        "/https://github.com/shaal/drupalpod"
      );
    }
  }
};

const app = {
  template: `
    <div class="vue-app">
      <h1>DrupalPod Launcher</h1>
      <br>
      <selector></selector>
    </div>
    `
};

// register your components
Vue.component("selector", selector);
Vue.component("app", app);

// launch your Vue app
new Vue({
  el: "#app",
  template: `<app></app>`
});
