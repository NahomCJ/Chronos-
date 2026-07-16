'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "7441caf476750a8986449bb4e0716d6f",
"assets/AssetManifest.bin.json": "04ede1fdccfe6aa0b4ec1d923278d15a",
"assets/AssetManifest.json": "fca41183575231099d02332fac3371ba",
"assets/assets/Abstract%2520Dimensions.png": "e303fea4651e7412e244c216c2312be6",
"assets/assets/auth_bg_img.png": "f75e51dfef235d9a7b1d2de21677354e",
"assets/assets/background.png": "4c94559177691cc235dd47c9b4cf099b",
"assets/assets/bg.jpg": "4c94559177691cc235dd47c9b4cf099b",
"assets/assets/btc.png": "8241dea13019f0b5f91ced64466820c3",
"assets/assets/Chromatic%2520Dreams.png": "60f891b013a381b770bd3a0e05d65a51",
"assets/assets/chronos.jpg": "6891d8a3f9baa4ad2c60e86cf338440f",
"assets/assets/Chronoslogo-icon-black.png": "caf60c2e56e55ab0a4c69b61cb3e7a9f",
"assets/assets/earbud.png": "4ccd4541006e9fa4fe2fda1ae7e15045",
"assets/assets/ethereum.png": "47d2f31321ba16fafcf5b0623900c846",
"assets/assets/forget.JSON": "d6d0267d6df5935bf038b9cafaf7905b",
"assets/assets/Founder%2520Image.jpg": "622a56aa02e1e63c9299d50c45904e06",
"assets/assets/Frame%2520blochub.png": "29b3c0a5dc56d7e8fb84d1ee90e72bb1",
"assets/assets/Geometric%2520Visions.png": "5f2b5d62d88d96df964aa4dd676e5959",
"assets/assets/headphone.png": "5f1f3b0447420b81835938a3bbd5bb80",
"assets/assets/home_bg.png": "5c3183e49a5787583c5a0bbfed0e899b",
"assets/assets/home_bg1.png": "2290ca4e5ce8d4042bcd2bd15c547f93",
"assets/assets/home_bg2.png": "539e85f80c6d681c8e6cf31110d15071",
"assets/assets/image1.jpg": "5ebadc131dfd388e5a016b3f30cbb389",
"assets/assets/image2.png": "11734441c7487b1b4f60a006b5d21ea4",
"assets/assets/lioness%25201.png": "64528a216521a9841710ce9e303d946a",
"assets/assets/login.JSON": "26321d27855a717be80b7380ca13bd30",
"assets/assets/MarketplaceHome.png": "fa394b62350d841cd1233faaaa5aa0e6",
"assets/assets/MarketplaceHome1.png": "51d47a3a54cb752b4e41bfa285d213b6",
"assets/assets/onboarding_1.png": "2d5fed39378560c0e8cbf5d5188d390d",
"assets/assets/onboarding_2.png": "2e320887367389a6e45f9a5b89f55281",
"assets/assets/onboarding_3.png": "54a624a9cda50808aafe1005c2f0e8e7",
"assets/assets/onboarding_4.png": "a98948dfe938a687c673e631dce632ec",
"assets/assets/onboarding_5.png": "a2cb3dd2db81ae3ea7113577abd399bf",
"assets/assets/panther.png": "b760c8c8f6c8ee5f94abf8af560b1fc6",
"assets/assets/panther_icon.png": "64528a216521a9841710ce9e303d946a",
"assets/assets/shoe1.png": "7a74034a473313d433dddd3b767e226a",
"assets/assets/smartwatch.png": "8a2bfa95359fe78d25f051fd7cd88c6f",
"assets/assets/solana.png": "d9639de9a2995bbae71d2d4775ce1370",
"assets/assets/splash_img.png": "130abcc325e080c93077599cbcd90b7b",
"assets/assets/tracker.png": "4b62f0cb2def48aa10ae3901deee3b49",
"assets/assets/Vector.png": "de7156c2115d25d28cf14b3b649e21f8",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/NOTICES": "190dd68e23ba9a37768e5bbbacf768f8",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "b93248a553f9e8bc17f1065929d5934b",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "6cfe36b4647fbfa15683e09e7dd366bc",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "ba4a8ae1a65ff3ad81c6818fd47e348b",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "9a27b8d4539c55d64d38b2af10cfc32c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "d29ecedcbfa0e4d8dccbde2eebfbd7c5",
"/": "d29ecedcbfa0e4d8dccbde2eebfbd7c5",
"main.dart.js": "7d4cd21b411a84bb4e65352926ce31cd",
"manifest.json": "70886f30e87ce2831a9839baed202a37",
"version.json": "269b08926cfbcaba620c78ed8d58f45f"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
