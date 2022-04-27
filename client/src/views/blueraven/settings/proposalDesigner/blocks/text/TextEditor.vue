<template>
  <fragment>
    <div v-if="editor">
      <bubble-menu
        class="bubble-menu"
        :tippy-options="{ duration: 100 }"
        :editor="editor"
      >
        <div>
          <button @click="editor.chain().focus().toggleBold().run()" :class="{ 'is-active': editor.isActive('bold') }">
            b
          </button>
          <button @click="editor.chain().focus().toggleItalic().run()"
                  :class="{ 'is-active': editor.isActive('italic') }">
            i
          </button>
          <button @click="editor.chain().focus().toggleStrike().run()"
                  :class="{ 'is-active': editor.isActive('strike') }">
            s
          </button>

          <button @click="editor.chain().focus().setParagraph().run()"
                  :class="{ 'is-active': editor.isActive('paragraph') }">
            p
          </button>
          <button @click="editor.chain().focus().toggleSuperscript().run()"
                  :class="{ 'is-active': editor.isActive('superscript') }">
            sup
          </button>
          <button @click="editor.chain().focus().toggleHeading({ level: 1 }).run()"
                  :class="{ 'is-active': editor.isActive('heading', { level: 1 }) }">
            h1
          </button>
          <button @click="editor.chain().focus().toggleHeading({ level: 2 }).run()"
                  :class="{ 'is-active': editor.isActive('heading', { level: 2 }) }">
            h2
          </button>
          <button @click="editor.chain().focus().toggleHeading({ level: 3 }).run()"
                  :class="{ 'is-active': editor.isActive('heading', { level: 3 }) }">
            h3
          </button>
          <button @click="editor.chain().focus().toggleHeading({ level: 4 }).run()"
                  :class="{ 'is-active': editor.isActive('heading', { level: 4 }) }">
            h4
          </button>
          <button @click="editor.chain().focus().toggleHeading({ level: 5 }).run()"
                  :class="{ 'is-active': editor.isActive('heading', { level: 5 }) }">
            h5
          </button>
          <button @click="editor.chain().focus().toggleHeading({ level: 6 }).run()"
                  :class="{ 'is-active': editor.isActive('heading', { level: 6 }) }">
            h6
          </button>
          <button @click="editor.chain().focus().toggleBulletList().run()"
                  :class="{ 'is-active': editor.isActive('bulletList') }">
            ul
          </button>
          <button @click="editor.chain().focus().toggleOrderedList().run()"
                  :class="{ 'is-active': editor.isActive('orderedList') }">
            ol
          </button>

          <button @click="editor.chain().focus().setHorizontalRule().run()">
            hr
          </button>
        </div>

        <div>
          <button @click="editor.chain().focus().insertTable({ rows: 4, cols: 2 }).run()">
            insertTable
          </button>
          <button @click="editor.chain().focus().addColumnBefore().run()" :disabled="!editor.can().addColumnBefore()">
            addColumnBefore
          </button>
          <button @click="editor.chain().focus().addColumnAfter().run()" :disabled="!editor.can().addColumnAfter()">
            addColumnAfter
          </button>
          <button @click="editor.chain().focus().deleteColumn().run()" :disabled="!editor.can().deleteColumn()">
            deleteColumn
          </button>
          <button @click="editor.chain().focus().addRowBefore().run()" :disabled="!editor.can().addRowBefore()">
            addRowBefore
          </button>
          <button @click="editor.chain().focus().addRowAfter().run()" :disabled="!editor.can().addRowAfter()">
            addRowAfter
          </button>
          <button @click="editor.chain().focus().deleteRow().run()" :disabled="!editor.can().deleteRow()">
            deleteRow
          </button>
          <button @click="editor.chain().focus().deleteTable().run()" :disabled="!editor.can().deleteTable()">
            deleteTable
          </button>
          <button @click="editor.chain().focus().mergeCells().run()" :disabled="!editor.can().mergeCells()">
            mergeCells
          </button>
          <button @click="editor.chain().focus().splitCell().run()" :disabled="!editor.can().splitCell()">
            splitCell
          </button>
<!--          <button @click="editor.chain().focus().toggleHeaderColumn().run()"-->
<!--                  :disabled="!editor.can().toggleHeaderColumn()">-->
<!--            toggleHeaderColumn-->
<!--          </button>-->
<!--          <button @click="editor.chain().focus().toggleHeaderRow().run()" :disabled="!editor.can().toggleHeaderRow()">-->
<!--            toggleHeaderRow-->
<!--          </button>-->
<!--          <button @click="editor.chain().focus().toggleHeaderCell().run()" :disabled="!editor.can().toggleHeaderCell()">-->
<!--            toggleHeaderCell-->
<!--          </button>-->
          <button @click="editor.chain().focus().mergeOrSplit().run()" :disabled="!editor.can().mergeOrSplit()">
            mergeOrSplit
          </button>
          <!--          TODO: run this before saving if there is a table-->
          <!--          <button @click="editor.chain().focus().fixTables().run()" :disabled="!editor.can().fixTables()">-->
          <!--            fixTables-->
          <!--          </button>-->
<!--          <button @click="editor.chain().focus().goToNextCell().run()" :disabled="!editor.can().goToNextCell()">-->
<!--            goToNextCell-->
<!--          </button>-->
<!--          <button @click="editor.chain().focus().goToPreviousCell().run()" :disabled="!editor.can().goToPreviousCell()">-->
<!--            goToPreviousCell-->
<!--          </button>-->
        </div>

        <!--        <button @click="editor.chain().focus().setTextAlign('left').run()" :class="{ 'is-active': editor.isActive({ textAlign: 'left' }) }">-->
        <!--          left-->
        <!--        </button>-->
        <!--        <button @click="editor.chain().focus().setTextAlign('center').run()" :class="{ 'is-active': editor.isActive({ textAlign: 'center' }) }">-->
        <!--          center-->
        <!--        </button>-->
        <!--        <button @click="editor.chain().focus().setTextAlign('right').run()" :class="{ 'is-active': editor.isActive({ textAlign: 'right' }) }">-->
        <!--          right-->
        <!--        </button>-->
        <!--        <button @click="editor.chain().focus().setTextAlign('justify').run()" :class="{ 'is-active': editor.isActive({ textAlign: 'justify' }) }">-->
        <!--          justify-->
        <!--        </button>-->

      </bubble-menu>

      <!--      <floating-menu-->
      <!--        class="floating-menu"-->
      <!--        :tippy-options="{ duration: 100 }"-->
      <!--        :editor="editor"-->
      <!--      >-->
      <!--        <button-->
      <!--          @click="editor.chain().focus().toggleHeading({ level: 1 }).run()"-->
      <!--          :class="{ 'is-active': editor.isActive('heading', { level: 1 }) }"-->
      <!--        >-->
      <!--          H1-->
      <!--        </button>-->
      <!--        <button-->
      <!--          @click="editor.chain().focus().toggleHeading({ level: 2 }).run()"-->
      <!--          :class="{ 'is-active': editor.isActive('heading', { level: 2 }) }"-->
      <!--        >-->
      <!--          H2-->
      <!--        </button>-->
      <!--        <button-->
      <!--          @click="editor.chain().focus().toggleBulletList().run()"-->
      <!--          :class="{ 'is-active': editor.isActive('bulletList') }"-->
      <!--        >-->
      <!--          Bullet List-->
      <!--        </button>-->
      <!--      </floating-menu>-->
    </div>
    <editor-content :editor="editor" />
  </fragment>
</template>
<script>

import { Fragment } from 'vue-frag'
import { BubbleMenu, Editor, EditorContent, FloatingMenu } from '@tiptap/vue-2'
import { extensions } from './utils'

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
    }
  },
  components: { EditorContent, BubbleMenu, FloatingMenu, Fragment },
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
      extensions,
      onBlur: () => {
        const payload = this.editor.getJSON()
        this.$emit('blur', { ...payload })
      }
    })
  },
  beforeDestroy() {
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

.bubble-menu {
  z-index: 1000;
  display: flex;
  background-color: #0d0d0d;
  padding: 0.2rem;
  border-radius: 0.5rem;

  button {
    border: none;
    background: none;
    color: #fff;
    font-size: 0.85rem;
    font-weight: 500;
    padding: 0 0.2rem;
    opacity: 0.6;

    &:hover,
    &.is-active {
      opacity: 1;
    }
  }
}

.floating-menu {
  display: flex;
  background-color: #0d0d0d10;
  padding: 0.2rem;
  border-radius: 0.5rem;

  button {
    border: none;
    background: none;
    font-size: 0.85rem;
    font-weight: 500;
    padding: 0 0.2rem;
    opacity: 0.6;

    &:hover,
    &.is-active {
      opacity: 1;
    }
  }
}

/* Table-specific styling */
.ProseMirror {
  &:focus-visible {
    outline: none;
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
