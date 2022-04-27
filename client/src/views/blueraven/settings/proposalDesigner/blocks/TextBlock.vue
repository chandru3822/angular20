<template>
  <div class="proposal-text" :style="styles">
    <!--    TODO: figure out a way to display this better (ie. it needs to display the fragment so it inherits parents properties correctly)-->
    <fragment v-if="!editable" v-html="html" />
    <text-editor v-else :value="blockValue" @blur="updateValue" />
  </div>
</template>
<script>
import TextEditor from './text/TextEditor'
import { generateHTMLFromJSON } from './text/utils'
import { mapState } from 'vuex'
import { Fragment } from 'vue-frag'
import { ProposalMutations } from '@/views/blueraven/settings/proposalDesigner/store'

export default {
  name: 'TextBlock',
  components: { TextEditor, Fragment },
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
      default: function() {
        return {}
      }
    }
  },
  computed: {
    html() {
      try {
        return generateHTMLFromJSON(this.blockValue)
      }catch(e){
        console.error("ID:", this.id, e)
        return ""
      }
    },
    styles() {
      const themeStyles = this.theme[this.themeKey] ?? {}
      return { ...themeStyles, ...this.blockStyle }
    },
    ...mapState({
      theme: (state) => state.proposal.theme
    })
  },
  methods: {
    updateValue(payload) {
      this.$store.commit(ProposalMutations.SET_VALUE, { blockId: this.id, value: payload })
    }
  }
}
</script>
