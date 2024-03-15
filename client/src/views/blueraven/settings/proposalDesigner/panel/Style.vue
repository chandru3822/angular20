<template>
  <fragment>
    <fragment v-if="type === 'TextBlock'">
      <div>
        <v-card-title>Typography</v-card-title>
        <v-btn-toggle v-model="cssStyle.textAlign">
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

        <v-text-field outlined dense
          v-model="cssStyle.fontWeight"
          label="Font Weight"
          @change="doUpdateStyles({'fontWeight': $event})"
        />
        <v-text-field outlined dense
                      v-model="cssStyle.lineHeight"
                      label="Line Height"
                      @change="doUpdateStyles({'lineHeight': $event})"
        />
        <size-widget label="Font Size" attr="fontSize" :value="cssStyle.fontSize" @input="doUpdateStyles($event)" />

      </div>

      <div>
        <v-card-title>Colors</v-card-title>
        <color-widget :value="cssStyle.color" @input="doUpdateStyles($event)">
          <template #title>
            <span class="flex-grow-1">
            Font Color
            </span>
          </template>
        </color-widget>

        <color-widget :value="cssStyle.backgroundColor" attr="backgroundColor" @input="doUpdateStyles($event)">
          <template #title>
            <span class="flex-grow-1">
            Background Color
            </span>
          </template>
        </color-widget>
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
              @click="doUpdateStyles({'@backgroundImage' : undefined })"
              color="unset"
              text="Clear Image"
          ></a-btn>
        </div>

        <v-select dense
          v-if="cssStyle.backgroundImage"
          v-model="cssStyle.backgroundSize"
          :items="backgroundSizeItems"
          label="Background Size"
          @change="doUpdateStyles({'backgroundSize': $event})"
        />
      </div>
      <!--      TODO: backgroundPosition-->

    </fragment>

    <div>
      <v-card-title>Props</v-card-title>
      <v-select outlined dense
                v-model="cssStyle.display"
                :items="displayItems"
                label="Display"
                @change="doUpdateStyles({'display': $event})"
      />

      <fragment v-if="isFlex">
        <v-select outlined dense
                  v-model="cssStyle.flexDirection"
                  :items="flexDirectionItems"
                  label="Direction"
                  @change="doUpdateStyles({'flexDirection': $event})"
        />
        <v-select outlined dense
                  v-model="cssStyle.justifyContent"
                  :items="flexJustifyItems"
                  label="Justify"
                  @change="doUpdateStyles({'justifyContent': $event})"
        />
        <v-select outlined dense
                  v-model="cssStyle.alignItems"
                  :items="flexAlignItems"
                  label="Align"
                  @change="doUpdateStyles({'alignItems': $event})"
        />
        <v-text-field outlined dense
                      v-model="cssStyle.flexBasis"
                      label="Flex Basis"
                      @change="doUpdateStyles({'flexBasis': $event})"
        />
      </fragment>
    </div>

    <div>
      <v-card-title>Padding</v-card-title>
      <space-widget attr="padding" :value="cssStyle.padding" @input="doUpdateStyles($event)"/>
    </div>
  </fragment>
</template>
<script setup>
import ImageSelectorWidget from './ImageSelectorWidget'

import SizeWidget from './SizeWidget'
import ColorWidget from './ColorWidget'
import SpaceWidget from './SpaceWidget'
import { Fragment } from 'vue-frag'
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
const props = defineProps({
  type: {
    type: String,
    required: true
  },
  cssStyle: {
    type: Object,
    required: false,
    default: function() {
      return {}
    }
  }
})

const emit = defineEmits(['input'])

const style = ref({})
const imageSelector = ref(null)
const paddingToggle = ref(null)
const displayItems = ref(['block', 'flex'])
const flexDirectionItems = ref(['row', 'row-reverse', 'column', 'column-reverse'])
const flexJustifyItems = ref(['flex-start', 'space-between', 'center', 'space-around', 'flex-end'])
const flexAlignItems = ref(['flex-start', 'center', 'flex-end'])
const backgroundSizeItems = ref(['auto', 'contain', 'cover'])

const isFlex = computed(() => {
  return props.cssStyle?.display === 'flex'
})

onMounted(() => {
  style.value = { ...props.cssStyle }
})

const doUpdateStyles = (styles) => {
  // console.log({styles, applied: {...this.cssStyle, ...styles}})
  emit('input', { ...props.cssStyle, ...styles })
}
const openSelectImage = async(attribute = '@backgroundImage') => {
  const result = await imageSelector.value.open()
  if (result?.uuid !== undefined) {
    doUpdateStyles({ [attribute]: result.uuid })
  }
}
</script>
<style lang="scss" scoped>

</style>
