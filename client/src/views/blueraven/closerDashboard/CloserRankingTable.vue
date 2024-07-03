 <template>
  <v-container id="closer-dash-container" ref="closerDashContainer">
    <v-data-table
      :items="tableData"
      :headers="tableHeaders"
      :footer-props="footerProps"
      :hide-default-footer="true"
    >

      <template #no-data>
        <span class="default-text-color">{{ noDataText }}</span>
      </template>

      <template #item.closerName="{item, index}">
        <div class="body-medium rep-container">
          <img v-if="item.userImageUrl" class="ranking-table-img"
                 :src="item.userImageUrl" :alt="item.userImageAltText">
          <img v-else class="placeholder-img"
               src="../../../assets/flow/user_img_placeholder.png" :alt="item.userImageAltText">
         {{item.closerName}}
        </div>
      </template>

      <template #item.rank="{item, index}" class="rank-column">
        <div class="body-medium">
          <v-icon v-if="item.rank === 1 || item.rank === 'T1'" class="first-trophy">
            mdi-trophy
          </v-icon>
          <v-icon v-if="item.rank === 2 || item.rank === 'T2'" class="second-trophy">
            mdi-trophy
          </v-icon>
          <v-icon v-if="item.rank === 3 || item.rank === 'T3'" class="third-trophy">
            mdi-trophy
          </v-icon>
          {{item.rank}}
        </div>
      </template>
    </v-data-table>

  </v-container>
</template>

<script setup>
  import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
  import { useUserStore } from "@/stores/UserStore.js";
  import {useRoute, useRouter} from "vue-router/composables";
  import { useAppStore } from '@/stores/AppStore.js'
  import constants from "@/helpers/constants.js";

  const appStore = useAppStore()
  const route = useRoute()
  const router = useRouter()
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const snackbar = vueInstance.$snackbar

  const props = defineProps({
    title: String,
    tableData: Array,
    tableHeaders: Array,
    noDataText: String
  })
  const { title, filterList, filterTypes, tableData, tableHeaders } = toRefs(props)

  const footerProps = ref({
    'items-per-page-options': [25, 50, 100, 500, 1000],
    'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
  })
</script>

<style lang="scss" scoped>
.rep-container{
  display: flex;
  align-items: center;
}
.ranking-table-img,
.placeholder-img {
  border-radius: 50%;
  padding: 1px;
  width: 28px;
  height: 28px;
  margin-right: 8px;
}

.first-trophy{
  color: #FCC417;
}

.second-trophy{
  color: #CECDD2;
}

.third-trophy{
  color: #F79429;
}

@media (min-width: 737px) {
  .ranking-table-img,
  .placeholder-img {
    width: 40px;
    height: 40px;
  }
}
</style>
