<template>
<v-card class="card pa-0" flat color="transparent">
  <v-card-text>
    <v-row no-gutters>
    <v-col>
      <v-row class="justify-end" no-gutters>
        <v-avatar
            v-if="imageUrl"
            :tile="false"
            :size="25"
            color="grey lighten-4"
            class="text-right mr-2"
        >
          <img name="accountImg" :src="imageUrl">
        </v-avatar>
        {{ name }}
      </v-row>
    </v-col>
  </v-row>
  <v-row>
    <v-col cols="12" class="text-right">{{ role }} | {{ location }}</v-col>
  </v-row>
  </v-card-text>
</v-card>
</template>

<script>
export default {
  name: 'UserCard',
  props: {
    name: String,
    role: String,
    location: String,
    imageUrl: String
  }
}
</script>


<style scoped lang="scss">
.card {
  font-size: 14px;
  font-weight: bold;
  width: 170px;
}

.card .v-card__text {
  padding: 0px;
}

.image-container {
  flex-grow: 0;
  margin-left: 5px;
  margin-right: 5px;
}

.name {
  font-size: 16px;
}

</style>
