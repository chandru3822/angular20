<template>
  <fragment>
    <editor-content :editor="editor" />
  </fragment>
</template>

<script>
import { Fragment } from 'vue-frag'
import { BubbleMenu, Editor, EditorContent } from '@tiptap/vue-2'
import { getExtensions } from './utils'

const defaultDocument = {
  type: 'doc',
  content: [
    {
      type: 'paragraph',
      content: [
        {
          type: 'text',
          text: ''
        }
      ]
    }
  ]
}

export default {
  name: 'TextEditor',
  props: {
    value: {
      type: Object,
      required: true
    },
    tags: {
      type: Array,
      required: false
    }
  },
  components: { EditorContent, BubbleMenu, Fragment },
  data() {
    return {
      editor: null
    }
  },
  watch: {
    value: function(val) {
      if (val) {
        this.editor?.commands?.setContent(val)
      }
    }
  },
  mounted() {
    const content = this.value ?? defaultDocument
    this.editor = new Editor({
      content,
      extensions: getExtensions({tags: this.tags}),
      onBlur: () => {
        const payload = this.editor.getJSON()
        this.$emit('blur', { ...payload })
      }
    })

    this.$emit('init', this.editor)
  },
  beforeDestroy() {
    //TODO: deregister editor
    this.editor.destroy()
  }
}
</script>

<style lang="scss">
.replacement {
  border-radius: 0.4rem;
  padding: 0.1rem;
  box-decoration-break: clone;
  background: rgb(255 255 255 / 70%);
  color: black;
  backdrop-filter: blur(10px);
}

/* Table-specific styling */
.ProseMirror {
  &:focus-visible {
    outline: none;
  }

  p  {
    padding: 0;
    margin: 0;
  }

  table {
    border-collapse: collapse;
    table-layout: fixed;
    width: 100%;
    margin: 0;
    overflow: hidden;

    td,
    th {
      min-width: 1em;
      border: 2px solid #ced4da;
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
      background-color: #f1f3f5;
    }

    .selectedCell:after {
      z-index: 2;
      position: absolute;
      content: "";
      left: 0;
      right: 0;
      top: 0;
      bottom: 0;
      background: rgba(200, 200, 255, 0.4);
      pointer-events: none;
    }

    .column-resize-handle {
      position: absolute;
      right: -2px;
      top: 0;
      bottom: -2px;
      width: 4px;
      background-color: #adf;
      pointer-events: none;
    }

    p {
      margin: 0;
    }
  }
}

.resize-cursor {
  cursor: ew-resize;
  //cursor: col-resize;
}

</style>
