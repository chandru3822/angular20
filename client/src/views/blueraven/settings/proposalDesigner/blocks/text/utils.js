import { generateHTML } from '@tiptap/core'
import StarterKit from '@tiptap/starter-kit'
import Superscript from '@tiptap/extension-superscript'
import TextAlign from '@tiptap/extension-text-align'
import Mention from '@tiptap/extension-mention'
import Table from '@tiptap/extension-table'
import TableCell from '@tiptap/extension-table-cell'
import TableRow from '@tiptap/extension-table-row'
import TableHeader from '@tiptap/extension-table-header'
import { VueRenderer } from '@tiptap/vue-2'
import tippy from 'tippy.js'
import Fuse from 'fuse.js'
import { getRequest } from '@/helpers/helpers'
import ReplacementList from './ReplacementList'

const suggestion = {
  char: '{',
  endChar: '}',
  items: (() => {
    let items = []
    //this is kind of janky but it loads the data only once
    getRequest('/proposal/template/tags', 'blueraven', [])
      .then(({ data }) => items = data)

    return ({ query }) => {
      if (query === '') {
        return items.slice(0, 10)
      }
      const fuse = new Fuse(items, { includeScore: true, threshold: 0.4, distance: 75 })
      return fuse.search(query).map(({ item }) => item).slice(0, 10)
    }
  })(),

  render: () => {
    let component
    let popup
    return {
      onStart: (props) => {
        component = new VueRenderer(ReplacementList, {
          parent: this,
          propsData: props
        })
        popup = tippy('body', {
          getReferenceClientRect: props.clientRect,
          appendTo: () => document.body,
          content: component.element,
          showOnCreate: true,
          interactive: true,
          trigger: 'manual',
          placement: 'bottom-start',
          maxWidth: 'none'
        })
      },

      onUpdate(props) {
        component.updateProps(props)

        popup[0].setProps({
          getReferenceClientRect: props.clientRect
        })
      },

      onKeyDown(props) {
        props.event.stopPropagation()

        if (props.event.key === 'Escape') {
          popup[0].hide()
          return true
        }

        return component.ref?.onKeyDown(props)
      },

      onExit() {
        setTimeout(() => {
          popup[0].destroy()
          component.destroy()
        }, 100)

      }
    }
  }
}

const extensions = [
  StarterKit,
  Superscript,
  TextAlign.configure({
    types: [],
    defaultAlignment: ''
  }),
  Mention.configure({
    suggestion,
    renderLabel({ options, node }) {
      return `${options.suggestion.char}${node.attrs.label ?? node.attrs.id}${
        options.suggestion.endChar
      }`
    },
    HTMLAttributes: {
      class: 'replacement'
    }
  }),
  Table.configure({
    resizable: true
  }),
  TableCell,
  TableRow,
  TableHeader
]

const generateHTMLFromJSON = (json) => {
  return generateHTML(json, extensions)
}

export { extensions, generateHTMLFromJSON }
