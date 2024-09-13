 <template>
  <v-container id="setter-dash-container" ref="setterDashContainer">
    <v-data-table
      :items="tableData"
      :headers="tableHeaders"
      :footer-props="footerProps"
      :hide-default-footer="true"
    >

      <template #no-data>
        <span class="default-text-color">{{ noDataText }}</span>
      </template>

      <template #item.name="{item, index}">
        <div class="body-medium">
<!--          <img v-if="item.userImageUrl" class="ranking-table-img"-->
<!--                 :src="item.userImageUrl" :alt="item.userImageAltText">-->
<!--          <img v-else class="placeholder-img"-->
<!--               src="../../../assets/flow/user_img_placeholder.png" :alt="item.userImageAltText">-->
          <v-avatar :tile="false" :size="35" color="grey lighten-4"
                    class="account-img mr-3" :class="{'mx-0 mr-n5':constants.IS_MOBILE}">
            <v-img name="accountImg" v-if="item.userImageUrl"
                   :src="item.userImageUrl"></v-img>
            <img :alt="item.userImageAltText" v-else src="../../../assets/flow/user_img_placeholder.png">
          </v-avatar>
         {{item.name}}
        </div>
      </template>

      <template #item.rank="{item, index}" class="rank-column">
        <div class="body-medium">
          <v-icon v-if="item.rank === '1' || item.rank === 'T1'" class="first-trophy">
            mdi-trophy
          </v-icon>
          <v-icon v-if="item.rank === '2' || item.rank === 'T2'" class="second-trophy">
            mdi-trophy
          </v-icon>
          <v-icon v-if="item.rank === '3' || item.rank === 'T3'" class="third-trophy">
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
.ranking-table-img,
.placeholder-img {
  border-radius: 50%;
  padding: 1px;
  width: 28px;
  height: 28px;
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
