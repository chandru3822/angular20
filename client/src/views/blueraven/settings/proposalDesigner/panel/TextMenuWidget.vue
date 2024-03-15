<template>
  <div class="d-flex flex-column justify-center align-center">
    <div>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().toggleBold().run()"
          :class="{ 'is-active': editor.isActive('bold') }"
          color="unset"
          prepend-icon="mdi-format-bold"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().toggleItalic().run()"
          :class="{ 'is-active': editor.isActive('italic') }"
          color="unset"
          prepend-icon="mdi-format-italic"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().toggleStrike().run()"
          :class="{ 'is-active': editor.isActive('strike') }"
          color="unset"
          prepend-icon="mdi-format-strikethrough"
      ></AlbatrossButton>

      <!--      TODO: add in font size -->
      <AlbatrossButton
          icon
          @click="editor.chain().focus().setParagraph().run()"
          :class="{ 'is-active': editor.isActive('paragraph') }"
          color="unset"
          prepend-icon="mdi-format-paragraph"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().toggleHeading({ level: 1 }).run()"
          :class="{ 'is-active': editor.isActive('heading', { level: 1 }) }"
          color="unset"
          prepend-icon="mdi-format-header-1"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().toggleHeading({ level: 2 }).run()"
          :class="{ 'is-active': editor.isActive('heading', { level: 2 }) }"
          color="unset"
          prepend-icon="mdi-format-header-2"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().toggleHeading({ level: 3 }).run()"
          :class="{ 'is-active': editor.isActive('heading', { level: 3 }) }"
          color="unset"
          prepend-icon="mdi-format-header-3"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().toggleHeading({ level: 4 }).run()"
          :class="{ 'is-active': editor.isActive('heading', { level: 4 }) }"
          color="unset"
          prepend-icon="mdi-format-header-4"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().toggleHeading({ level: 5 }).run()"
          :class="{ 'is-active': editor.isActive('heading', { level: 5 }) }"
          color="unset"
          prepend-icon="mdi-format-header-5"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().toggleHeading({ level: 6 }).run()"
          :class="{ 'is-active': editor.isActive('heading', { level: 6 }) }"
          color="unset"
          prepend-icon="mdi-format-header-6"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().toggleSuperscript().run()"
          :class="{ 'is-active': editor.isActive('superscript') }"
          color="unset"
          prepend-icon="mdi-format-superscript"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().toggleBulletList().run()"
          :class="{ 'is-active': editor.isActive('bulletList') }"
          color="unset"
          prepend-icon="mdi-format-list-bulleted"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().toggleOrderedList().run()"
          :class="{ 'is-active': editor.isActive('orderedList') }"
          color="unset"
          prepend-icon="mdi-format-list-numbered"
      ></AlbatrossButton>

      <AlbatrossButton
          icon
          @click="editor.chain().focus().setHorizontalRule().run()"
          color="unset"
          prepend-icon="mdi-minus"
      ></AlbatrossButton>
    </div>

    <div>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().insertTable({ rows: 4, cols: 2 }).run()"
          color="unset"
          prepend-icon="mdi-table-plus"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().addColumnBefore().run()"
          :disabled="!editor.can().addColumnBefore()"
          color="unset"
          prepend-icon="mdi-table-column-plus-before"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().addColumnAfter().run()"
          :disabled="!editor.can().addColumnAfter()"
          color="unset"
          prepend-icon="mdi-table-column-plus-after"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().deleteColumn().run()"
          :disabled="!editor.can().deleteColumn()"
          color="unset"
          prepend-icon="mdi-table-column-remove"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().addRowBefore().run()"
          :disabled="!editor.can().addRowBefore()"
          color="unset"
          prepend-icon="mdi-table-row-plus-before"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().addRowAfter().run()"
          :disabled="!editor.can().addRowAfter()"
          color="unset"
          prepend-icon="mdi-table-row-plus-after"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().deleteRow().run()"
          :disabled="!editor.can().deleteRow()"
          color="unset"
          prepend-icon="mdi-table-row-remove"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().deleteTable().run()"
          :disabled="!editor.can().deleteTable()"
          color="unset"
          prepend-icon="mdi-table-remove"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().mergeCells().run()"
          :disabled="!editor.can().mergeCells()"
          color="unset"
          prepend-icon="mdi-table-merge-cells"
      ></AlbatrossButton>
      <AlbatrossButton
          icon
          @click="editor.chain().focus().splitCell().run()"
          :disabled="!editor.can().splitCell()"
          color="unset"
          prepend-icon="mdi-table-split-cell"
      ></AlbatrossButton>
    </div>
  </div>
</template>
<script setup>
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"

const props = defineProps({
  editor: {
    type: Object,
    required: true
  }
})
</script>
<style lang="scss" scoped>
.is-active {
  background-color: #d0d0d066;
}
</style>
