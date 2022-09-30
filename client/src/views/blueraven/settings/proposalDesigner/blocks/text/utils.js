import '@tiptap/extension-text-style'

import { Extension, generateHTML } from '@tiptap/core'
import StarterKit from '@tiptap/starter-kit'
import TextStyle from '@tiptap/extension-text-style'
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


const FontConfig = Extension.create({
  name: 'fontConfig',

  addOptions() {
    return {
      types: ['textStyle']
    }
  },

  addGlobalAttributes() {
    return [
      {
        types: this.options.types,
        attributes: {
          color: {
            default: null,
            parseHTML: element => element.style.color?.replace(/['"]+/g, ''),
            renderHTML: attributes => {
              if (!attributes.color) {
                return {}
              }

              return {
                style: `color: ${attributes.color}`
              }
            }
          },
          fontSize: {
            default: null,
            parseHTML: element => element.style.fontSize?.replace(/['"]+/g, ''),
            renderHTML: attributes => {
              if (!attributes.fontSize) {
                return {}
              }

              return {
                style: `font-size: ${attributes.fontSize}`
              }
            }
          },
          fontWeight: {
            default: null,
            parseHTML: element => element.style.fontWeight?.replace(/['"]+/g, ''),
            renderHTML: attributes => {
              if (!attributes.fontWeight) {
                return {}
              }

              return {
                style: `font-weight: ${attributes.fontWeight}`
              }
            }
          }
        }
      }
    ]
  },

  addCommands() {
    return {
      setFontColor: color => ({ chain }) => {
        return chain()
          .setMark('textStyle', { color })
          .run()
      },
      unsetFontColor: () => ({ chain }) => {
        return chain()
          .setMark('textStyle', { color: null })
          .removeEmptyTextStyle()
          .run()
      },

      setFontSize: fontSize => ({ chain }) => {
        return chain()
          .setMark('textStyle', { fontSize })
          .run()
      },
      unsetFontSize: () => ({ chain }) => {
        return chain()
          .setMark('textStyle', { fontSize: null })
          .removeEmptyTextStyle()
          .run()
      },

      setFontWeight: fontWeight => ({ chain }) => {
        return chain()
          .setMark('textStyle', { fontWeight })
          .run()
      },
      unsetFontWeight: () => ({ chain }) => {
        return chain()
          .setMark('textStyle', { fontWeight: null })
          .removeEmptyTextStyle()
          .run()
      }
    }
  }
})

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
  TextStyle,
  FontConfig,
  TextAlign.configure({
    types: [],
    defaultAlignment: ''
  }),
  Mention.configure({
    suggestion,
    renderLabel({ options, node }) {
      return `${options.suggestion.char}VARIABLE${options.suggestion.endChar}`
      // return `${options.suggestion.char}${node.attrs.label ?? node.attrs.id}${options.suggestion.endChar}`
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
