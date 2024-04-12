### Opening Script Tag
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
<script>
```
</td>
<td>

```
<script setup>
```
</td>
</tr>
</table>

### Store and instance definition (not required in Vue2)
<table>
<tr>
<th>Vue3</th>
</tr>
<tr>
<td>

```
import { getCurrentInstance, ref } from 'vue'
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
```
</td>
</tr>
</table>

### Using a store value
<table>
<tr>
<th>Vue2</th>
</tr>
<tr>
<td>

```
(old) userCanEdit: this.$store.getters.userHasFeatureAccessLevel('CONTACTS', 'EDIT'),
(new) userCanEdit: this.userStore.userHasFeatureAccessLevel('CONTACTS', 'EDIT'),
```
</td>
</tr>
</table>
<table>
<tr>
<th>Vue3</th>
</tr>
<tr>
<td>

```
(old) const userCanAdd = store.getters.userHasFeatureAccessLevel('SMARTLIST', 'ADD')
(new) const userCanAdd = userStore.userHasFeatureAccessLevel('SMARTLIST', 'ADD')
```
</td>
</tr>
</table>

### Filters
<table>
<tr>
<th>Vue2</th>
</tr>
<tr>
<td>

```
{{ myDateValue | formatDate('date', 'MM/DD/YYYY')}}

OR

this.$filters(myDateValue, 'date', 'MM/DD/YYYY')
```
</td>
</tr>
</table>
<table>
<tr>
<th>Vue3</th>
</tr>
<tr>
<td>

```
const filters = vueInstance.$filters
filters.formatDate(myDateValue, 'date', 'MM/DD/YYYY')
```
</td>
</tr>
</table>


### Mixins
Note: Composition API doesn't have mixins
<table>
<tr>
<th>Vue2</th>
</tr>
<tr>
<td>

```
<template v-for="(item, index) in filterBy(items, true, 'show')">
mixins: [Vue2Filters.mixin],
```
</td>
</tr>
</table>
<table>
<tr>
<th>Vue3</th>
</tr>
<tr>
<td>

```
<template v-for="(item, index) in filteredItems">
import { computed } from 'vue'
const filteredItems = computed(() => {
  return items.value.filter(i => i.show)
})
```
</td>
</tr>
</table>

### Dynamic values (values that can change after screen load)
Note: ALL values inside of vue2 `export data()` will need to become `const` values, adding `ref` just makes them dynamic <br><br>
Definition <br>
Template Usage <br>
Script Usage <br>
Updating Value
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
statesLoading: false
{{statesLoading}}
this.statesLoading
this.statesLoading = true
```
</td>
<td>

```
const statesLoading = ref(false)
{{statesLoading}}
statesLoading.value
statesLoading.value = true
```
</td>
</tr>
</table>

### On Create/Mounted behavior
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
  created() {
    this.getUserPositionIds();
  },
```
</td>
<td>

```
import { onMounted } from 'vue'
onMounted(() => {
  getDesignReviewDetails()
})
```
</td>
</tr>
</table>

### Using Custom Components
<table>
<tr>
<th>Vue2</th>
</tr>
<tr>
<td>

```
import ConfirmationDialog from "@/components/ConfirmationDialog"
export default {
 components: { ConfirmationDialog }
}
<ConfirmationDialog/>
```
</td>
</tr>
</table>

<table>
<tr>
<th>Vue3</th>
</tr>
<tr>

<td>

```
import SmartlistCopy from '@/views/flow/smartlist/SmartlistCopy.vue'
<smartlist-copy/> OR <SmartlistCopy/>
```
</td>
</tr>
</table>

### Computed Values
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
computed: {
  canAdd() {
    return hasAddAccess || hasManageAccess
  }
}
```
</td>
<td>

```
import { computed } from 'vue'
const canAdd = computed(() => {
  return hasAddAccess || hasManageAccess
})
```
</td>
</tr>
</table>

### Sortable
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
let _self = this
...use _self in the function like:
_self.workQueueTypes.splice(newIndex, 0, rowSelected)
_self.saveRowChanges(rowsToSave)
```
</td>
<td>

```
...no need for scope/_self
workQueueTypes.value.splice(newIndex, 0, rowSelected)
saveRowChanges(rowsToSave)
```
</td>
</tr>
</table>

### Using Vue Router
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
this.$router.push('/login')
```
</td>
<td>

```
const router = vueInstance.$router
router.push('/login')
```
</td>
</tr>
</table>

### Using Route Params
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
this.$route.params.projectId
```
</td>
<td>

```
vueInstance.$route.params?.projectId
```
</td>
</tr>
</table>

### Component Props
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
props: {
  pageName: String
}
```
</td>
<td>

```
import {defineProps} from 'vue'
const props = defineProps({
  pageName: String
})
```
</td>
</tr>
</table>


### Basic Method
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
async doStuff(myProps) {}
```
</td>
<td>

```
const doStuff = async (myProps) => {})
```
</td>
</tr>
</table>


### Snackbar
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
snackbar: {}, <-- in the data
this.snackbar = getSnackbar('ERROR', 'Error Loading Announcements')
this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
```
</td>
<td>

```
const snackbar = 
 appStore.showSnack('SUCCESS', 'Announcement Saved')
```
</td>
</tr>
</table>

### Global Loader
Note: Global Loader handling is to prevent a loader from screenA still being present on screenB if the user navigates before screenA is done loading. Not to be confused with SET_LOADING = false
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
handleHidingGlobalLoader(this, status)
```
</td>
<td>

```
handleHidingGlobalLoader(vueInstance, status)
```
</td>
</tr>
</table>

### Form Validation
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
<v-form ref="resetPassword" ...
this.$refs.resetPassword.validate()
```
</td>
<td>

```
<v-form ref="resetPassword" ...
const resetPassword = ref(null)
resetPassword.value.validate()
```
</td>
</tr>
</table>

### Emits
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
this.$emit('clearSearch', param)
```
</td>
<td>

```
const emit = defineEmits(['clearSearch'])
emit('clearSearch', param)
```
</td>
</tr>
</table>

### Watchers
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
watch: {
  options () {
    //do stuff
  }
  
  OR, when the watched prop is like:
  
watch: {
  '$route.params.id': function () {
    //do stuff
  }  
}
```
</td>
<td>

```
import { watch } from 'vue'
watch(options, () => {
  //do stuff
})

OR, when the watched prop is like:
  
watch(() => vueInstance.$route.params.id, () => {
  //do stuff
}  
```
</td>
</tr>
</table>

### Before Route Leave
Note: Same behavior for Before Route Update
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
beforeRouteLeave(to, from, next) {
  //do stuff
  next()
}
```
</td>
<td>

```
import { onBeforeRouteLeave } from 'vue-router/composables'
onBeforeRouteLeave(async (to, from, next) => {
  //do stuff
  next()
})
```
</td>
</tr>
</table>

### Before Route Enter
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
  beforeRouteEnter(to, from, next) {
    next((vm) => {
      //do stuff
    });
  },
```
</td>
<td>

```
WIP:
need to solve when we come to it
```
</td>
</tr>
</table>

### Before Destroy
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
beforeDestroy() {
  //do stuff
}
```
</td>
<td>

```
onBeforeUnmount(() => {
  //doStuff
})
```
</td>
</tr>
</table>

### Deep CSS
<table>
<tr>
<th>Vue2</th>
<th>Vue3</th>
</tr>
<tr>
<td>

```
#title-container ::v-deep .v-toolbar__content {
  width: 100%;
}
```
</td>
<td>

```
#title-container :deep(.v-toolbar__content) {
  width: 100%;
}
```
</td>
</tr>
</table>
