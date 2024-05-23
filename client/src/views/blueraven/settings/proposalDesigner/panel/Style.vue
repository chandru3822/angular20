<template>
  <fragment>
    <fragment v-if="type === 'TextBlock'">
      <div>
        <v-card-title class="px-0 title-medium">Typography</v-card-title>
        <v-card-text class="pb-0">
        <v-btn-toggle v-model="cssStyle.textAlign" class="pb-4">
          <a-btn
            size="small"
            value="left"
            color="unset"
            prepend-icon="mdi-format-align-left"
          ></a-btn>

          <a-btn
            size="small"
            value="center"
            color="unset"
            prepend-icon="mdi-format-align-center"
          ></a-btn>

          <a-btn
            size="small"
            value="right"
            color="unset"
            prepend-icon="mdi-format-align-right"
          ></a-btn>

          <a-btn
            size="small"
            value="justify"
            color="unset"
            prepend-icon="mdi-format-align-justify"
          ></a-btn>
        </v-btn-toggle>

        <a-text-field
          density="compact"
          variant="outlined"
          v-model="cssStyle.fontWeight"
          label="Font Weight"
          hint="Can be a keyword like 'bold', 'light', or a number like 700"
          persistent-hint
          class="pb-2"
          @change="doUpdateStyles({ fontWeight: $event })"
        />
        <a-text-field
          density="compact"
          variant="outlined"
          v-model="cssStyle.lineHeight"
          label="Line Height"
          @change="doUpdateStyles({ lineHeight: $event })"
        />
        <size-widget
          label="Font Size"
          attr="fontSize"
          :value="cssStyle.fontSize"
          @input="doUpdateStyles($event)"
        />
        </v-card-text>
      </div>

      <div>
        <v-card-title class="px-0 py-0">Colors</v-card-title>
        <v-card-text class="pb-0">
        <color-widget :value="cssStyle.color" @input="doUpdateStyles($event)">
          <template #title>
            <span class="flex-grow-1 label-medium"> Font Color </span>
          </template>
        </color-widget>

        <color-widget
          :value="cssStyle.backgroundColor"
          attr="backgroundColor"
          @input="doUpdateStyles($event)"
        >
          <template #title>
            <span class="flex-grow-1 label-medium"> Background Color </span>
          </template>
        </color-widget>
        </v-card-text>
      </div>
    </fragment>
    <!--    -->
    <fragment v-if="type === 'PageBlock' || type === 'ContainerBlock'">
      <div>
        <v-card-title>Background</v-card-title>
        <div>
          <image-selector-widget ref="imageSelector" />
          <a-btn
            @click="openSelectImage('@backgroundImage')"
            color="unset"
            text="Open Image"
          ></a-btn>
          <a-btn
            variant="text"
            @click="doUpdateStyles({ '@backgroundImage': undefined })"
            color="unset"
            text="Clear Image"
          ></a-btn>
        </div>

        <a-select
          density="compact"
          v-if="cssStyle.backgroundImage"
          v-model="cssStyle.backgroundSize"
          :items="backgroundSizeItems"
          label="Background Size"
          @change="doUpdateStyles({ backgroundSize: $event })"
        />
      </div>
      <!--      TODO: backgroundPosition-->
    </fragment>

    <div>
      <v-card-title class="px-0">Props</v-card-title>
      <v-card-text>
      <a-select
        variant="outlined"
        density="compact"
        v-model="cssStyle.display"
        :items="displayItems"
        label="Display"
        @change="doUpdateStyles({ display: $event })"
      />

      <fragment v-if="isFlex">
        <span class="label-large pb-2">Flex Options</span>
        <div class="px-1">
        <a-select
          variant="outlined"
          density="compact"
          v-model="cssStyle.flexDirection"
          :items="flexDirectionItems"
          label="Flex Direction"
          @change="doUpdateStyles({ flexDirection: $event })"
        />
        <a-select
          variant="outlined"
          density="compact"
          v-model="cssStyle.justifyContent"
          :items="flexJustifyItems"
          label="Justify"
          @change="doUpdateStyles({ justifyContent: $event })"
        />
        <a-select
          variant="outlined"
          density="compact"
          v-model="cssStyle.alignItems"
          :items="flexAlignItems"
          label="Align"
          @change="doUpdateStyles({ alignItems: $event })"
        />
        <a-text-field
          density="compact"
          variant="outlined"
          v-model="cssStyle.flexBasis"
          label="Flex Basis"
          hint="Initial size: can be 'auto', an number, or a width like '50px'"
          persistent-hint
          @change="doUpdateStyles({ flexBasis: $event })"
        />
        </div>
      </fragment>
      </v-card-text>
    </div>

    <div>
      <v-card-title class="px-0 pt-0">Padding</v-card-title>
      <v-card-text class="pb-0">
      <space-widget
        attr="padding"
        :value="cssStyle.padding"
        @input="doUpdateStyles($event)"
      />
      </v-card-text>
    </div>
  </fragment>
</template>
<script setup>
import ImageSelectorWidget from './ImageSelectorWidget'

import SizeWidget from './SizeWidget'
import ColorWidget from './ColorWidget'
import SpaceWidget from './SpaceWidget'
import { Fragment } from 'vue-frag'
import { computed, ref, onMounted } from 'vue'

const emit = defineEmits(['input'])

const props = defineProps({
  type: {
    type: String,
    required: true
  },
  cssStyle: {
    type: Object,
    required: false,
    default: function () {
      return {}
    }
  }
})

const style = ref({})
const imageSelector = ref(null)
const paddingToggle = ref(null)
const displayItems = ref(['block', 'flex'])
const flexDirectionItems = ref([
  'row',
  'row-reverse',
  'column',
  'column-reverse'
])
const flexJustifyItems = ref([
  'flex-start',
  'space-between',
  'center',
  'space-around',
  'flex-end'
])
const flexAlignItems = ref(['flex-start', 'center', 'flex-end'])
const backgroundSizeItems = ref(['auto', 'contain', 'cover'])

const isFlex = computed(() => {
  return props.cssStyle?.display === 'flex'
})

onMounted(() => {
  style.value = { ...props.cssStyle }
})

const doUpdateStyles = (styles) => {
  emit('input', { ...props.cssStyle, ...styles })
}
const openSelectImage = async (attribute = '@backgroundImage') => {
  const result = await imageSelector.value.open()
  if (result?.uuid !== undefined) {
    doUpdateStyles({ [attribute]: result.uuid })
  }
}
</script>
