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
userCanEdit: this.$store.getters.userHasFeatureAccessLevel('CONTACTS', 'EDIT'),
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
const userCanAdd = store.getters.userHasFeatureAccessLevel('SMARTLIST', 'ADD')
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
const props = defineProps({
  pageName: String
})
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
}
```
</td>
<td>

```
import { watch } from 'vue'
watch(options, () => {
  //do stuff
})
```
</td>
</tr>
</table>

### Before Route Leave
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
