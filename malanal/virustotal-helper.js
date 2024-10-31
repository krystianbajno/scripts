// https://www.virustotal.com/gui/search/    <hash>
// paste it into devtools and then invoke

const Virustotal = () => ({
    scan: (hash) => {
        window.location = `https://www.virustotal.com/gui/search/${hash}`
    },
    get: () => ({
        info: () => {
        },
        detections: () => {
        },
        behavior: () => {
        },
        details: () => {
        }
    }),
    download: () => ({
        info: () => {
            const info = VirustotalHelper().get().info()
        },
        detections: () => {
            const detections = VirustotalHelper().get().detections()
        },
        behavior: () => {
            const behavior = VirustotalHelper().get().behavior()
        },
        details: () => {
            const details = VirustotalHelper().get().details()
        },
        all: () => {
            const info = VirustotalHelper().get().info()
            const detections = VirustotalHelper().get().detections()
            const behavior = VirustotalHelper().get().behavior()
            const details = VirustotalHelper().get().details()
        }
    }),
    __download__: (data) => {

    },
    __click__: (element) => {}
})