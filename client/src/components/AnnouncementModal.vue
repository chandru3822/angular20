<template>
  <v-card class="coversheet-container" >
    <v-card-text class="px-3 pb-4 pt-3" v-if="!announcement">
      <SpinnerInline  :size="20" color="primary"/>
    </v-card-text>
    <v-card-text class="px-3 pb-4 pt-3" v-else>
      <v-toolbar flat dense class="app-toolbar announcement-toolbar">
        <v-toolbar-title class="title-large">{{ announcement.title }}</v-toolbar-title>
        <v-spacer/>
        <v-toolbar-items>
          <v-btn x-small text color="primary" @click="closeModal()">
            <v-icon>close</v-icon>
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <div class="px-4 pt-4">
        <div class="announcement-subtitle">{{announcement.subtitle}}</div>
        <div v-if="announcement.presignedUrl" class="py-3">
          <img class="announcement-image" :src="announcement.presignedUrl">
        </div>
        <div :class="{'pt-3': !announcement.presignedUrl}">
        <a class="announcement-hyperlink"
           v-if="announcement.hyperlink" target="_blank"
           :href="announcement.hyperlink">
          {{announcement.hyperlink}}
        </a>
        </div>
        <div class="mt-2" v-if="announcement.description">
          <quill-editor
              :options="toolbarOptions"
              class="rich-text-editor rich-text-editor-readonly albatross-body-2"
              :readonly="true"
              :disabled="true"
              v-model=announcement.description
          />
        </div>
      </div>
    </v-card-text>
  </v-card>
</template>

<script>

import 'quill/dist/quill.snow.css'
import { quillEditor } from 'vue-quill-editor'
import SpinnerInline from '@/components/SpinnerInline'

export default {
  name: "AttachmentCoversheetModal",
  props: {
    announcement: Object,
    closeCallback: Function,
  },
  components: {
    QuillEditor: quillEditor,
    SpinnerInline
  },
  watch: {},
  data() {
    return {
      toolbarOptions: {
        modules: {
          toolbar: [
            ['bold', 'italic', 'underline', 'blockquote'], //toggled buttons
            //without the color array then black = false which just un-sets color. in our case our default is navy blue, so unsetting the color goes back to navy blue and not to black.  by setting the black value to #000000 it fixes this issue.  when our default color changes to black then we could just remove the colors in this array to use the defaults from quill
            [{ 'color': ['#000000', '#e60000', '#ff9900', '#ffff00', '#008a00', '#0066cc', '#9933ff', '#ffffff', '#facccc', '#ffebcc', '#ffffcc', '#cce8cc', '#cce0f5', '#ebd6ff', '#bbbbbb', '#f06666', '#ffc266', '#ffff66', '#66b966', '#66a3e0', '#c285ff', '#888888', '#a10000', '#b26b00', '#b2b200', '#006100', '#0047b2', '#6b24b2', '#444444', '#5c0000', '#663d00', '#666600', '#003700', '#002966', '#3d1466'] },
              { 'background': [] }],          // dropdown with defaults from theme
            [{ 'size': ['small', false, 'large', 'huge'] }],  // custom dropdown
            ['clean']                                         // remove all formatting button
          ]
        }
      },
    }
  },
  created() {

  },
  computed: {
    isMobile(){
      return this.$vuetify.breakpoint.smAndDown
    },

  },
  methods: {
    closeModal() {
      this.closeCallback()
    },
  }
}
</script>

<style lang="scss">
.rich-text-editor-readonly .ql-toolbar {
  display: none;
}

.rich-text-editor-readonly .ql-container {
  //border-top: solid 1px #ccc !important;
  border:none;
  border-radius: 0.25em;
  background-color: #fff !important;
  padding: 0;
}

.rich-text-editor-readonly ul {
  padding-left: 0;
}

.rich-text-editor-readonly .ql-editor {
  padding: 10px 0;
}

.rich-text-editor .ql-container {
  height: auto !important;
  width: 100%;
  color: rgba(0,0,0,0.87); //default-text-color
  font-size: 1rem; //body-large
  font-weight: 400;
  font-family: lato;
  line-height: 1.6;
}
</style>

<style lang="scss" scoped>
.announcement-image {
  max-width: 100%;
  height: auto;
  max-height: 380px;
  width: auto;
}

.announcement-toolbar {
  border-bottom: none !important;
}

.announcement-subtitle {
  color: rgba(0, 0, 0, 0.87);
  font-size: 14px;
}

.announcement-hyperlink {
  font-size: 16px;
  font-weight: 600;
}

</style>
