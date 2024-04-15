<template>
  <v-main>
    <v-container>
      <v-row class="">
        <v-col cols="6">
          <div class="header">
            <h3 class="">Paste the options data here</h3>
            <v-checkbox dense hide-details label="Auto copy to clipboard?" v-model="autoCopyToClipboard"></v-checkbox>
            <v-checkbox dense hide-details label="Reset and Refocus on Paste?" v-model="resetFieldsOnPaste"></v-checkbox>
          </div>
        </v-col>
        <v-col cols="6">
          <div class="header">
            <div class="d-flex">
              <h3 class="">Composition Code</h3>
              <a-btn icon class="ml-5" color="primary" size="small"
                               v-if="compositionValue"
                               @click="copyToClipboard" prepend-icon="mdi-content-copy"></a-btn>
            </div>
          </div>
        </v-col>
      </v-row>
      <v-row class="data-container">
        <v-col cols="6">
          <a-textarea v-model="optionsValue"
                      variant="outlined"
                      @input="optionsValueInput()"
                      ref="inputField"
                      auto-grow
                      label="Data Value" />
        </v-col>
        <v-col cols="6" class="">
          <a-textarea variant="outlined" v-model="compositionValue" auto-grow>
          </a-textarea>
        </v-col>
      </v-row>
      <v-row class="py-3">
        <v-col cols="12">
          <a-btn
              :disabled="!optionsValue"
              @click="processBtn" text="Submit"></a-btn>
          <a-btn class="ml-4" variant="text"
                           @click="doClear" text="Clear"></a-btn>
        </v-col>
      </v-row>
    </v-container>
  </v-main>
</template>

<script setup>
import {onMounted, ref} from 'vue'

const optionsValue = ref(null)
const compositionValue = ref(null)
const inputField = ref(null)
const autoCopyToClipboard = ref(true)
const resetFieldsOnPaste = ref(true)

//for testing
// optionsValue.value = `      footerProps: {
// 'items-per-page-options': [25, 50, 100, 500],
//     'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
// },
// `

onMounted(() => {
  // processBtn()
})


const processBtn = async () => {
  let jsonString = optionsValue.value

  let stringArray = jsonString.split('\n')

  let newStringArray = []
  let insideArray = false
  let arrayPlaceholder = ''
  let insideObject = false
  let objectPlaceholder = ''
  stringArray.forEach((str, idx) => {
    str = str?.trim()
    let firstTwoChars = str.substring(0,2)
    //dont include any comments
    if(firstTwoChars !== '//') {
      //check if inside of array and combine till the end of array
      if(!insideArray && !insideObject && str.includes('[') && !str.includes(']')) {
        insideArray = true
        arrayPlaceholder = str
      } else if (insideArray) {
        arrayPlaceholder = arrayPlaceholder + str
        if(str === '],' || str === ']') {
          insideArray = false
          newStringArray.push(arrayPlaceholder)
          arrayPlaceholder = ''
        }
      } else if(!insideObject && str.includes('{') && !str.includes('}')) {
        insideObject = true
        objectPlaceholder = str
      } else if (insideObject) {
        objectPlaceholder = objectPlaceholder + str
        if(str === '},' || str === '}') {
          insideObject = false
          newStringArray.push(objectPlaceholder)
          objectPlaceholder = ''
        }
      } else if (str) {
        newStringArray.push(str)
      }
    }
  })

  let constStringArray = []
  newStringArray.forEach(a => {
    let indexOfColon = a.indexOf(':')
    let lastChar = a.slice(-1);
    let finalIndex = lastChar === ',' ? a.length - 1 : a.length
    let keyString = a.substring(0, indexOfColon)
    let valueString = a.substring(indexOfColon + 1, finalIndex).trim()
    if(keyString != null && valueString != null && keyString !== '') {
      let newRef = `const ${keyString} = ref(${valueString})`
      newRef = newRef.replaceAll('([{', '([\n{')
      newRef = newRef.replaceAll('},{', '},\n{')
      newRef = newRef.replaceAll('}])', '}\n])')
      newRef = newRef.replaceAll('},])', '},\n])')
      newRef = newRef.replaceAll(',\'', ',\n\'')
      newRef = newRef.replaceAll('ref({\'', 'ref({\n\'')
      newRef = newRef.replaceAll('\'})', '\'\n})')
      newRef = newRef.replaceAll('this.$store.state.brs', 'brsStore')
      newRef = newRef.replaceAll('this.$route', 'route')

      constStringArray.push(newRef)
    }
  })

  compositionValue.value = constStringArray.join('\n')
  if(autoCopyToClipboard.value) {
    copyToClipboard()
  }
  if(resetFieldsOnPaste.value) {
    doClear()
  }
}


const optionsValueInput = () => {
  compositionValue.value = null
  if(resetFieldsOnPaste.value) {
    processBtn()
  }
}

const doClear = () => {
  optionsValue.value = null
  compositionValue.value = null
  inputField.value.focus()
}

const copyToClipboard = () => {
  navigator.clipboard.writeText(compositionValue.value);
  appStore.showSnack('SUCCESS', `Copied to clipboard`)
}

</script>

<style scoped lang="scss">
.header {
  height: 75px;
  //background: blue;
}

.data-container {
  max-height: calc(100vh - 345px);
  overflow: auto;
}
</style>
