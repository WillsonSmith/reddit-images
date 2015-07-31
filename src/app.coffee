container = document.getElementById("container");
form = document.getElementById("subreddit-form");
search_box = form.getElementsByTagName("input")[0];

saved_states = {
  last_search: ""
  after_id: null
}

clearImages = ->
  container.innerHTML = "";

hashHandler = ->
  {
    initialize: ->
      this.handle();
      window.addEventListener "hashchange", =>
        this.handle();
    handle: (hash) ->
      if hash
        location.hash = hash
      else
        getSubredditContent(location.hash.substr(1)) if location.hash;
  }

createImageElement = (image_array) ->
  container_element = document.createElement("section");
  image_link = document.createElement("a");
  image_container = document.createElement("div");
  image_element = document.createElement("img");

  container_element.classList.add("image-container")

  for image in image_array
    image_link = image_link.cloneNode(false);
    image_container = image_container.cloneNode(false);
    image_element = image_element.cloneNode(false);

    image_container.classList.add("column-item");
    image_link.href = image;
    image_element.src = image;

    image_link.appendChild(image_element);
    image_container.appendChild(image_link);
    container_element.appendChild(image_container);
  container_element

putImagesOnScreen = (image_array) ->
  container.appendChild(createImageElement(image_array));

getImagesFromData = (data) ->
  posts = data.data.children;
  image_links = [];
  for post in posts
    post_type = post.data.post_hint;
    post_url = post.data.url;
    image_links.push(post_url) if post_type == "image" and post_url unless post_url in image_links
  image_links

getSubredditContent = (subreddit, after = "") ->

  fetch "https://www.reddit.com/r/#{subreddit}.json?after=#{after}"
  .then (response) ->
    return response.json();
  .then (data) ->
    saved_states.last_search = subreddit;
    saved_states.after_id = data.data.after if data.data.after;
    putImagesOnScreen(getImagesFromData(data)) unless "error" of data;
  .catch (error) ->
    console.log(error);

startFormListener = ->
  form.addEventListener "submit", (e) ->
    e.preventDefault();
    subreddit = search_box.value;
    if subreddit
      clearImages();
      hashHandler().handle(subreddit);
      getSubredditContent(subreddit);
    else
      clearImages();

startScrollListener = ->
  window.addEventListener "scroll", ->
    scroll_height = document.documentElement.scrollHeight
    page_Y_offset = window.pageYOffset
    client_height = document.documentElement.clientHeight
    getSubredditContent(saved_states.last_search, saved_states.after_id) if scroll_height - (page_Y_offset + client_height) < 50;


initialize = ->
  hashHandler().initialize();
  startFormListener();
  startScrollListener();

initialize();
