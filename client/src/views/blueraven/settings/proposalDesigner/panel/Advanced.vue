<template>
  <v-card flat>
    <v-card-title class="px-0">Advanced</v-card-title>
    <v-card-text>
    <a-text-field
      density="compact"
      variant="outlined"
      v-model="expression"
      label="Visibility"
      hint="This expression must evaluate to a boolean"
      @change="handleChange"
      clearable
    >
      <template v-slot:append-outer>
        <v-dialog v-model="dialog" width="500">
          <template v-slot:activator="{ on: dialogOn, attrs }">
            <v-fade-transition leave-absolute>
              <a-btn icon :activation-handler="dialogOn">
                <template #default>
                  <v-tooltip bottom>
                    <template v-slot:activator="{ on }">
                      <v-icon v-on="on" v-bind="attrs">
                        mdi-help-circle-outline
                      </v-icon>
                    </template>
                    Available variables
                  </v-tooltip>
                </template>
              </a-btn>
            </v-fade-transition>
          </template>

          <v-card>
            <v-card-title class="albatross-header-2 lighten-2 pb-1">
              Allowed Variables
            </v-card-title>

            <v-card-text>
              <ul>
                <li v-for="tag in tags">
                  {{ tag.tagName }} [{{ tag.tagType }}]
                </li>
              </ul>
            </v-card-text>

            <v-divider />

            <v-card-actions>
              <v-spacer />
              <a-btn
                color="primary"
                variant="text"
                @click="dialog = false"
                text="Done"
              ></a-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
      </template>
    </a-text-field>
    </v-card-text>
  </v-card>
</template>
<script setup>
import { toRefs, ref, watch } from 'vue'
import useProposalStore from '../store.js'
import { storeToRefs } from 'pinia'

const store = useProposalStore()

const props = defineProps({
  visibility: {
    type: String
  }
})
const emit = defineEmits(['input'])

const { visibility } = toRefs(props)
const expression = ref(undefined)
const dialog = ref(false)

const { tags } = storeToRefs(store)

watch(visibility, async (arg) => {
  expression.value = arg
})

const handleChange = () => {
  emit('input', expression)
}
</script>
