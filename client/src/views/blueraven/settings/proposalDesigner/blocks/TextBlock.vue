<template>
  <div class="proposal-text" :style="styles">
    <fragment v-if="!editable" v-html="html" v-bind="$attrs"/>
    <text-editor v-else :value="blockValue" @blur="updateValue" @init="register" :tags="tags"/>
  </div>
</template>
<script>
import TextEditor from './text/TextEditor'
import {generateHTMLFromJSON} from './text/utils'
import {mapState} from 'vuex'
import {Fragment} from 'vue-frag'
import {ProposalMutations} from '@/views/blueraven/settings/proposalDesigner/store'

const xmlSerializer = new XMLSerializer()

export default {
  name: 'TextBlock',
  components: {TextEditor, Fragment},
  props: {
    id: {
      required: true
    },
    blockValue: {
      type: Object,
      required: true
    },
    themeKey: {
      type: String
    },
    editable: {
      type: Boolean
    },
    blockStyle: {
      type: Object,
      default: function () {
        return {}
      }
    }
  },
  data() {
    return {
      html: ''
    }
  },
  computed: {
    styles() {
      const themeStyles = this.theme[this.themeKey] ?? {}
      return {...themeStyles, ...this.blockStyle}
    },
    ...mapState({
      theme: (state) => state.proposal.theme,
      tags: (state) => state.proposal.tags?.map(t => t.tagName)
    })
  },
  watch: {
    blockValue: {
      immediate: true,
      handler: function (newVal) {
        this.html = this.generateHtml(newVal)
      }
    }
  },
  methods: {
    updateValue(payload) {
      this.$store.commit(ProposalMutations.SET_VALUE, {blockId: this.id, value: payload})
    },
    register(editor) {
      this.$store.commit(ProposalMutations.REGISTER_EDITOR, {blockId: this.id, editor})
    },
    generateHtml(val) {
      try {
        //trick the fragment into always updating
        const commentEl = document.createComment(`fragment#id=${this.id} last_updated=${new Date().valueOf()}`)
        const serializeToString = xmlSerializer.serializeToString(commentEl)
        const htmlFromJSON = generateHTMLFromJSON(val)

        return serializeToString + htmlFromJSON
      } catch (e) {
        console.error('ID:', this.id, e)
      }
      return ''
    }
  }
}
</script>

<style lang="scss">
.proposal-text {
  table {
    border-collapse: collapse;
    table-layout: fixed;
    width: 100%;
    margin: 0;
    overflow: hidden;

    td,
    th {
      min-width: 1em;
      padding: 3px 5px;
      vertical-align: top;
      box-sizing: border-box;
      position: relative;

      > * {
        margin-bottom: 0;
      }
    }

    th {
      font-weight: bold;
      text-align: left;
    }

    p {
      margin: 0;
    }
  }

  p {
    margin: 0;
  }
}
</style>
