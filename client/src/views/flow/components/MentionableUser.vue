<template>
  <div class="row" style="padding: 5px;">
    <div class="col-md-12">
      <div class="container-fluid">
          <span>
              <img v-if="url != null"
                   :src="url"
                   class="user default-user-size"
                   :style="sizeStyle"/>
          </span>
          <span class="left-space text-center">
              <strong>{{username}}</strong>
          </span>
      </div>
    </div>
  </div>
</template>

<script>
import $ from 'jquery'

export default {
  name: 'mentionable-user',
  props: {
    size: {
      type: [Number, String],
      required: false
    },
    mention: {
      type: Object,
      required: false
    },
    showDefaultAvatar: {
      type: Boolean,
      required: false,
      default: true
    }
  },
  data() {
    return {
      users: []
    }
  },
  computed: {
    username() {
      return this.mention.fullName;
    },
    url() {
      return this.mention.awsBucket;
    },
    sizeStyle() {
      const size = parseInt(this.size);
      if (size) {
        return {
          'min-width': `${size}px`,
          'width': `${size}px`,
          'min-height': `${size}px`,
          'height': `${size}px`,
          'line-height': `${size}px`,
        }
      } else {
        return null;
      }
    }
  },
  created() {
    $(".auto-complete li").hover(function() {
      $(this).addClass("active");
    }, function() {
      $(this).removeClass("active");
    });
  }
}
</script>

<style scoped>
.user {
  display: inline-block;
  -webkit-border-radius: 30px;
  -moz-border-radius: 30px;
  border-radius: 30px;
}
.default-user-size {
  width: 30px;
  height: 35px;
  line-height: 35px;
}
.left-space {
  margin-left: 5px;
}
</style>
