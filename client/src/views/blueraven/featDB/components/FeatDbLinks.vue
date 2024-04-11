<!-- suppress CssInvalidPseudoSelector -->
<template id="feat-db-links">
  <FeatDbCard
      :title="title"
      :expanded-all="expandedAll"
      :edit-mode="editMode"
      show-add show-expanded
      :user-can-edit="userCanEdit"
      :add-btn-disabled="!linkInfoEntered"
      @hide-ctrls="hideCtrls"
      @save-new="saveLink(true)"
      @save-update="saveLink(false)"
      @delete-item="deleteLink"
      @toggle-collapse-expand="$emit('toggle-collapse-expand', $event)"
  >
    <template v-slot:addOrEdit>
      <v-form
          ref="linkForm">
        <a-text-field v-model="selectedLink.name" required label="Name" filled></a-text-field>
        <a-text-field v-model="selectedLink.link" required type="url"
                      :rules="[urlRule]" label="URL" filled></a-text-field>
        <a-text-field v-model="selectedLink.username" label="Username" filled></a-text-field>
        <a-text-field v-model="selectedLink.password" label="Password" filled></a-text-field>
        <a-textarea label="Notes" auto-grow
                    variant="filled"
                    style="margin: 15px 0 -15px 0"
                    v-model="selectedLink.notes">
        </a-textarea>
      </v-form>
    </template>
    <v-list v-show="links.length > 0" v-for="(link, index) of links"
            :key="link.id" class="px-2" :style="{'border-radius': index === links.length - 1 ? '5px !important' : '',
                                                 'border': index === links.length - 1 ? 'none !important' : ''}">
      <v-list-item :title="link.name">
        <v-list-item-content class="flex-row-center">
          <v-list-item-action @click="editLink(link)" v-if="userCanEdit">
            <v-icon small color="primary">edit</v-icon>
          </v-list-item-action>
          <v-list-item-title
              :style="[{'font-size': isNested ? '0.95em !important' : '0.85em !important'}, {'text-align': 'left'}]">
            <a :href="link.link" target="_blank" class="list-link">{{ link.name }}</a>
          </v-list-item-title>
        </v-list-item-content>
      </v-list-item>
    </v-list>
    <div class="empty-list" v-show="links.length < 1"
         :style="{'font-size': isNested ? '0.95em !important' : '0.85em !important'}">
      No links found
    </div>
  </FeatDbCard>
</template>

<script setup>
import cloneDeep from 'lodash.clonedeep'


import {putRequest, postRequest, } from '@/helpers/helpers'
import {CollapseExpandEnum} from "@/views/blueraven/featDB/FeatDbConstants";
import FeatDbCard from "@/views/blueraven/featDB/components/FeatDbCard.vue";
import {getCurrentInstance, toRefs, computed, ref, onMounted, watch} from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import {useAppStore} from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar


const props = defineProps({
  title: String,
  linkTypeId: Number,
  userCanEdit: Boolean,
  itemId: Number,
  itemType: String,
  ahjId: Number,
  links: {
    type: Array,
    default: () => []
  },
  isNested: {
    type: Boolean,
    default: false
  },
  showExpanded: {
    type: Boolean,
    default: false
  },
  expandedAll: CollapseExpandEnum
})
const {
  title,
  linkTypeId,
  userCanEdit,
  itemId,
  itemType,
  ahjId,
  links,
  isNested,
  showExpanded,
  expandedAll
} = toRefs(props)

const linkForm = ref(null)
const selectedLink = ref({})
const editMode = ref(false)
const validUrl = ref(false)
const linksCopy = ref(links.value)

const linkInfoEntered = computed(() => {
  return selectedLink.value.name && selectedLink.value.link && validUrl.value
})

const urlRule = (url) => {
  if (url && (!url.includes('http://') && !url.includes('https://')) || (url === 'http://' || url === 'https://')) {
    validUrl.value = false
    return 'Valid URL is required'
  } else {
    validUrl.value = true
    return true
  }
}
const hideCtrls = () => {
  linkForm.value.reset()
  editMode.value = false
}
const editLink = (link) => {
  editMode.value = true
  selectedLink.value = Object.assign({}, link)
}
const saveLink = async (newLink) => {
  appStore.loading = true
  selectedLink.value.linkTypeId = linkTypeId.value

  if (newLink) {
    try {
      let res = null
      //changed to not require updates when a new feat_db gets added
      if (['permit', 'inspection', 'design'].includes(itemType.value)) {
        res = await postRequest(`/featDb/ahj/${ahjId.value}/${itemType.value}/${itemId.value}/links`, selectedLink.value, 'blueraven')
      } else {
        res = await postRequest(`/featDb/${itemType.value}/${itemId.value}/links`, selectedLink.value, 'blueraven')
      }

      linksCopy.value.push(cloneDeep(res.data))
      snackbar('SUCCESS', 'Link added')
      linkForm.value.reset()
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error adding link')
    }
  } else {
    try {
      let res = null
      //changed to not require updates when a new feat_db gets added
      if (['permit', 'inspection', 'design'].includes(itemType.value)) {
        res = await putRequest(`/featDb/ahj/${ahjId.value}/${itemType.value}/${itemId.value}/links/${selectedLink.value.id}`, selectedLink.value, 'blueraven')
      } else {
        res = await putRequest(`/featDb/${itemType.value}/${itemId.value}/links/${selectedLink.value.id}`, selectedLink.value, 'blueraven')
      }

      let updatedLinkIndex = linksCopy.value.findIndex(i => i.id === res.data.id)
      linksCopy.value[updatedLinkIndex].name = res.data.name
      linksCopy.value[updatedLinkIndex].link = res.data.link
      linksCopy.value[updatedLinkIndex].username = res.data.username
      linksCopy.value[updatedLinkIndex].password = res.data.password
      linksCopy.value[updatedLinkIndex].notes = res.data.notes
      snackbar('SUCCESS', 'Link updated')
      linkForm.value.reset()
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error adding link')
    }
  }
  appStore.loading = false
}
const deleteLink = async () => {
  console.log('3222',selectedLink.value)
  appStore.loading = true

  try {
    //changed to not require updates when a new feat_db gets added
    if (['permit', 'inspection', 'design'].includes(itemType.value)) {
      await putRequest(`/featDb/ahj/${ahjId.value}/${itemType.value}/${itemId.value}/links/${selectedLink.value.id}/archive`, null, 'blueraven')
    } else {
      await putRequest(`/featDb/${itemType.value}/links/${selectedLink.value.id}/archive`, null, 'blueraven')
    }

    let deletedLinkIndex = linksCopy.value.findIndex(i => i.id === selectedLink.value.id)
    linksCopy.value.splice(deletedLinkIndex, 1)
    snackbar('SUCCESS', 'Link deleted')
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error deleting link')
  }
  appStore.loading = false
}
</script>

<style scoped lang="scss">
.flex-row-center {
  display: flex;
  flex-flow: row nowrap;
  align-items: center;
}

.cancel-link {
  font-size: 0.85em !important;
  text-decoration: none;
}

.list-link {
  text-decoration: none;
}

.cancel-link:hover,
.list-link:hover {
  text-decoration: underline;
}

.v-card__title,
.v-toolbar__title {
  font-size: 1em !important;
}

.v-text-field,
.v-input ::v-deep label {
  font-size: 0.95em !important;
}

.v-list {
  border-bottom: 1px solid var(--v-primary-base) !important;
  border-radius: 0;
}

.v-list__item__title {
  font-size: 0.8em !important;
}

.v-list-item__action {
  margin: 0 10px 0 0 !important;
  max-width: 30px;
  height: 30px;
  border: 1px solid var(--v-primary-base) !important;
  border-radius: 3px;
  display: flex;
  justify-content: center;
  cursor: pointer;
}

.link-btns {
  display: flex;
  flex-flow: row nowrap;
  justify-content: flex-end;
  align-items: center;

  button {
    margin: 0 0 0 7px;
  }
}

.empty-list {
  padding: 20px;
  text-align: left;
}
</style>
